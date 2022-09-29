# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalController, type: :controller do
  describe '#create_user' do
    before do
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(
        uid: Faker::Internet.uuid,
        info: {
          email: Faker::Internet.email,
          name: Faker::Name.name
        }
      )
    end

    let!(:role) { create(:role, name: 'User') }

    it 'creates the user if the info returned is valid' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      expect do
        get :create_user, params: { provider: 'openid_connect' }
      end.to change(User, :count).by(1)
    end

    it 'logs the user in and redirects to their rooms page' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(session[:session_token]).to eq(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).session_token)
      expect(response).to redirect_to('/rooms')
    end

    it 'assigns the User role to the user' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).role).to eq(role)
    end

    context 'ResyncOnLogin' do
      let!(:user) do
        create(:user,
               external_id: OmniAuth.config.mock_auth[:openid_connect]['uid'],
               name: 'Example Name',
               email: 'email@example.com')
      end

      it 'overwrites the saved values with the values from the authentication provider if true' do
        allow_any_instance_of(SettingGetter).to receive(:call).and_return(true)

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        get :create_user, params: { provider: 'openid_connect' }

        user.reload
        expect(user.name).to eq(OmniAuth.config.mock_auth[:openid_connect]['info']['name'])
        expect(user.email).to eq(OmniAuth.config.mock_auth[:openid_connect]['info']['email'])
      end

      it 'does not overwrite the saved values with the values from the authentication provider if false' do
        allow_any_instance_of(SettingGetter).to receive(:call).and_return(false)

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        get :create_user, params: { provider: 'openid_connect' }

        user.reload
        expect(user.name).to eq('Example Name')
        expect(user.email).to eq('email@example.com')
      end
    end
  end

  describe '#recording_ready' do
    let(:room) { create(:room) }

    before do
      allow_any_instance_of(BigBlueButtonApi).to receive(:decode_jwt).and_return(
        [{
          'record_id' => sample_recording[:recordID],
          'meeting_id' => room.meeting_id
        }]
      )
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_recording).and_return(sample_recording)
      allow_any_instance_of(RecordingCreator).to receive(:call).and_return(nil)
    end

    it 'decrements a rooms recordings processing value if recording doesnt exist' do
      expect do
        post :recording_ready
      end.to change { room.reload.recordings_processing }.by(-1)
    end

    it 'does not decrement the recordings processing value if the recording already exists' do
      create(:recording, record_id: sample_recording[:recordID])

      expect do
        post :recording_ready
      end.not_to(change { room.reload.recordings_processing })
    end

    it 'calls RecordingCreator with the right values' do
      expect(RecordingCreator).to receive(:new).with(recording: sample_recording).and_call_original

      post :recording_ready
    end
  end

  describe '#meeting_ended' do
    let(:room) { create(:room) }

    it 'increments a rooms recordings processing value if the meeting was recorded' do
      get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'true' }
      expect(room.reload.recordings_processing).to eq(1)
      get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'true' }
      expect(room.reload.recordings_processing).to eq(2)
    end

    it 'does not increment a rooms recordings processing value if the meeting was not recorded' do
      get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'false' }
      expect(room.reload.recordings_processing).to eq(0)
    end
  end

  private

  def sample_recording
    {
      recordID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
      meetingID: 'random-1291479',
      internalMeetingID: 'f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
      name: 'random-1291479',
      isBreakout: 'false',
      published: true,
      state: 'published',
      startTime: 'Wed, 11 May 2022 12:43:48 -0400'.to_datetime,
      endTime: 'Wed, 11 May 2022 12:44:20 -0400'.to_datetime,
      participants: '1',
      rawSize: '977816',
      metadata: { isBreakout: 'false', meetingId: 'random-1291479', meetingName: 'random-1291479' },
      size: '305475',
      playback: {
        format: {
          type: 'presentation',
          url: 'https://test24.bigbluebutton.org/playback/presentation/2.3/f0e2be4518868febb0f381ebe7d46ae61364ef1e-1652287428125',
          processingTime: '6386',
          length: 0,
          size: '305475'
        }
      },
      data: {}
    }
  end
end
