# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalController, type: :controller do
  let(:fake_setting_getter) { instance_double(SettingGetter) }

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

      allow(SettingGetter).to receive(:new).and_call_original
      allow(SettingGetter).to receive(:new).with(setting_name: 'DefaultRole', provider: 'greenlight').and_return(fake_setting_getter)
      allow(fake_setting_getter).to receive(:call).and_return('User')
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
      expect(response).to redirect_to(root_path)
    end

    it 'assigns the User role to the user' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).role).to eq(role)
    end

    it 'marks the user as verified' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).verified?).to be true
    end

    it 'looks the user up based on external id' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      create(:user, external_id: request.env['omniauth.auth']['uid'])

      expect do
        get :create_user, params: { provider: 'openid_connect' }
      end.to change(User, :count).by(0)
    end

    it 'looks the user up based on email' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      create(:user, email: request.env['omniauth.auth']['info']['email'])

      expect do
        get :create_user, params: { provider: 'openid_connect' }
      end.to change(User, :count).by(0)
    end

    context 'redirect' do
      it 'redirects to the location cookie if a relative redirection 1' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: '/rooms/o5g-hvb-s44-p5t/join',
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to('/rooms/o5g-hvb-s44-p5t/join')
      end

      it 'redirects to the location cookie if its a legacy url (3 sections in uid)' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: '/rooms/o5g-hvb-s44/join',
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to('/rooms/o5g-hvb-s44/join')
      end

      it 'redirects to the location cookie if a relative redirection 2' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: '/a/b/c/d/rooms/o5g-hvb-s44-p5t/join',
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to('/a/b/c/d/rooms/o5g-hvb-s44-p5t/join')
      end

      it 'doesnt redirect if NOT a relative redirection check 1' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: Faker::Internet.url,
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to(root_path)
      end

      it 'doesnt redirect if it NOT a relative redirection format check 2' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: 'https://www.google.com?ignore=/rooms/iam-abl-eto-pas/join',
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to(root_path)
      end

      it 'doesnt redirect if it NOT a relative redirection format check 3' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: "http://example.com/?ignore=\n/rooms/abc-def-ghi-jkl/join",
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to(root_path)
      end

      it 'doesnt redirect if NOT a relative redirection check 4' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: Faker::Internet.url(path: '/rooms/o5g-hvb-s44-p5t/join'),
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to(root_path)
      end

      it 'doesnt redirect if NOT a valid room join link check 5' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: '/romios/o5g-hvb-s44-p5t/join',
          path: '/'
        }
        get :create_user, params: { provider: 'openid_connect' }

        expect(response).to redirect_to(root_path)
      end

      it 'deletes the cookie after reading' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        cookies[:location] = {
          value: '/rooms/o5g-hvb-s44-p5t/join',
          path: '/'
        }

        get :create_user, params: { provider: 'openid_connect' }

        expect(cookies[:location]).to be_nil
      end
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

      it 'does not overwrite the role even if true' do
        allow_any_instance_of(SettingGetter).to receive(:call).and_return(true)
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        new_role = create(:role)
        user.update(role: new_role)

        get :create_user, params: { provider: 'openid_connect' }

        expect(user.reload.role).to eq(new_role)
      end
    end

    context 'Registration Method' do
      context 'invite' do
        before do
          reg_method = instance_double(SettingGetter)
          allow(SettingGetter).to receive(:new).with(setting_name: 'RegistrationMethod', provider: 'greenlight').and_return(reg_method)
          allow(reg_method).to receive(:call).and_return('invite')
        end

        it 'creates a user account if they have a valid invitation' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]
          invite = create(:invitation, email: OmniAuth.config.mock_auth[:openid_connect][:info][:email])
          cookies[:inviteToken] = {
            value: invite.token
          }

          expect { get :create_user, params: { provider: 'openid_connect' } }.to change(User, :count).by(1)
        end

        it 'deletes an invitation after using it' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]
          invite = create(:invitation, email: OmniAuth.config.mock_auth[:openid_connect][:info][:email])
          cookies[:inviteToken] = {
            value: invite.token
          }

          expect { get :create_user, params: { provider: 'openid_connect' } }.to change(Invitation, :count).by(-1)
        end

        it 'allows a user with an existing account to sign in without a token' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

          create(:user, external_id: OmniAuth.config.mock_auth[:openid_connect][:uid])

          expect { get :create_user, params: { provider: 'openid_connect' } }.not_to raise_error
          expect(response).to redirect_to(root_path)
        end

        it 'returns an InviteInvalid error if no invite is passed' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

          get :create_user, params: { provider: 'openid_connect' }

          expect(response).to redirect_to(root_path(error: Rails.configuration.custom_error_msgs[:invite_token_invalid]))
        end

        it 'returns an InviteInvalid error if the token is wrong' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]
          create(:invitation, email: OmniAuth.config.mock_auth[:openid_connect][:info][:email])
          cookies[:inviteToken] = {
            value: '123'
          }

          get :create_user, params: { provider: 'openid_connect' }

          expect(response).to redirect_to(root_path(error: Rails.configuration.custom_error_msgs[:invite_token_invalid]))
        end
      end

      context 'approval' do
        before do
          reg_method = instance_double(SettingGetter)
          allow(SettingGetter).to receive(:new).with(setting_name: 'RegistrationMethod', provider: 'greenlight').and_return(reg_method)
          allow(reg_method).to receive(:call).and_return(SiteSetting::REGISTRATION_METHODS[:approval])
        end

        it 'sets a user to pending when registering' do
          request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

          expect { get :create_user, params: { provider: 'openid_connect' } }.to change(User, :count).by(1)

          expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email])).to be_pending
          expect(response).to redirect_to(controller.pending_path)
        end
      end
    end

    context 'Role mapping' do
      let!(:role1) { create(:role, name: 'role1') }

      before do
        role_map = instance_double(SettingGetter)
        allow(SettingGetter).to receive(:new).with(setting_name: 'RoleMapping', provider: 'greenlight').and_return(role_map)
        allow(role_map).to receive(:call).and_return(
          "role1=#{OmniAuth.config.mock_auth[:openid_connect][:info][:email].split('@')[1]}"
        )
      end

      it 'Creates a User and assign a role if a rule matches their email' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

        expect { get :create_user, params: { provider: 'openid_connect' } }.to change(User, :count).by(1)
        expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).role).to eq(role1)
      end
    end
  end

  describe '#recording_ready' do
    let(:room) { create(:room, recordings_processing: 1) }

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
    let(:room) { create(:room, online: true) }

    context 'Recorded session' do
      it 'sets online to false' do
        get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'true' }

        expect(room.reload.online).to be(false)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({})
      end

      it 'increments a rooms recordings processing value if the meeting was recorded' do
        get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'true' }
        expect(room.reload.recordings_processing).to eq(1)

        get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'true' }
        expect(room.reload.recordings_processing).to eq(2)
      end
    end

    context 'Unrecorded session' do
      it 'sets online to false without incrementing a rooms recordings processing' do
        expect do
          get :meeting_ended, params: { meetingID: room.meeting_id, recordingmarks: 'false' }
        end.not_to(change { room.reload.recordings_processing })

        expect(room.online).to be(false)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'Inexistent room' do
      it 'silently fail' do
        get :meeting_ended, params: { meetingID: '404', recordingmarks: 'false' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({})
      end
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
