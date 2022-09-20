# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomSettingsController, type: :controller do
  let(:user) { create(:user) }
  let(:room) { create(:room, user:) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#show' do
    let(:room_setting_getter_service) { instance_double(RoomSettingsGetter) }

    before do
      allow(RoomSettingsGetter).to receive(:new).and_return(room_setting_getter_service)
      allow(room_setting_getter_service).to receive(:call).and_return({ 'setting' => 'value' })
    end

    it 'uses "RoomSettingGetter" service and render its returned value' do
      expect(RoomSettingsGetter).to receive(:new).with(room_id: room.id, current_user: user, provider: 'greenlight', show_codes: true,
                                                       only_enabled: true)
      expect(room_setting_getter_service).to receive(:call)

      get :show, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({ 'setting' => 'value' })
    end

    context 'AuthN' do
      it 'returns :unauthorized response for unauthenticated requests' do
        session[:user_id] = nil

        get :show, params: { friendly_id: room.friendly_id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#update' do
    it 'uses MeetingOption::get_config_value and updates the setting if its config is "optional"' do
      expect(MeetingOption).to receive(:get_config_value).and_call_original
      expect(MeetingOption).to receive(:get_config_value).with(name: 'setting', provider: 'greenlight').and_call_original

      meeting_option = create(:meeting_option, name: 'setting')
      create(:rooms_configuration, meeting_option:, value: 'optional')

      put :update, params: { room_setting: { settingName: 'setting', settingValue: 'notOptionalAnymore' }, friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
      expect(room.room_meeting_options.take.value).to eq('notOptionalAnymore')
    end

    context 'Access codes' do
      it 'uses MeetingOption::get_config_value and generates a code if it\'s not disabled and the value is "true"' do
        random_access_code_name = %w[glViewerAccessCode glModeratorAccessCode].sample
        expect(MeetingOption).to receive(:get_config_value).and_call_original
        expect(MeetingOption).to receive(:get_config_value).with(name: random_access_code_name, provider: 'greenlight').and_call_original
        allow_any_instance_of(described_class).to receive(:generate_code).and_return('CODE!!')
        expect_any_instance_of(described_class).to receive(:generate_code)

        meeting_option = create(:meeting_option, name: random_access_code_name)
        create(:rooms_configuration, meeting_option:, provider: 'greenlight', value: %w[optional true].sample)

        put :update, params: { room_setting: { settingName: random_access_code_name, settingValue: true }, friendly_id: room.friendly_id }
        expect(response).to have_http_status(:ok)
        expect(room.room_meeting_options.take.value).to eq('CODE!!')
      end

      it 'uses MeetingOption::get_config_value and removes a code if it\'s optional and the value is "false"' do
        random_access_code_name = %w[glViewerAccessCode glModeratorAccessCode].sample
        expect(MeetingOption).to receive(:get_config_value).and_call_original
        expect(MeetingOption).to receive(:get_config_value).with(name: random_access_code_name, provider: 'greenlight').and_call_original
        expect_any_instance_of(described_class).not_to receive(:generate_code)

        meeting_option = create(:meeting_option, name: random_access_code_name)
        create(:rooms_configuration, meeting_option:, provider: 'greenlight', value: 'optional')

        put :update, params: { room_setting: { settingName: random_access_code_name, settingValue: false }, friendly_id: room.friendly_id }
        expect(response).to have_http_status(:ok)
        expect(room.room_meeting_options.take.value).to be_empty
      end

      context 'AuthZ' do
        it 'returns :forbidden when value is "true" but the setting is disabled' do
          random_access_code_name = %w[glViewerAccessCode glModeratorAccessCode].sample
          expect(MeetingOption).to receive(:get_config_value).and_call_original
          expect(MeetingOption).to receive(:get_config_value).with(name: random_access_code_name, provider: 'greenlight').and_call_original
          expect_any_instance_of(described_class).not_to receive(:generate_code)

          meeting_option = create(:meeting_option, name: random_access_code_name)
          create(:rooms_configuration, meeting_option:, provider: 'greenlight', value: 'false')

          put :update, params: { room_setting: { settingName: random_access_code_name, settingValue: true }, friendly_id: room.friendly_id }
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns :forbidden when value is "false" but the setting is NOT optional' do
          random_access_code_name = %w[glViewerAccessCode glModeratorAccessCode].sample
          expect(MeetingOption).to receive(:get_config_value).and_call_original
          expect(MeetingOption).to receive(:get_config_value).with(name: random_access_code_name, provider: 'greenlight').and_call_original
          expect_any_instance_of(described_class).not_to receive(:generate_code)

          meeting_option = create(:meeting_option, name: random_access_code_name)
          create(:rooms_configuration, meeting_option:, provider: 'greenlight', value: %w[true false].sample)

          put :update, params: { room_setting: { settingName: random_access_code_name, settingValue: false }, friendly_id: room.friendly_id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'AuthZ' do
      it 'returns :forbidden if the setting config is "true"' do
        meeting_option = create(:meeting_option, name: 'setting')
        create(:rooms_configuration, meeting_option:, value: 'true')

        put :update, params: { room_setting: { settingName: 'setting', settingValue: 'notTrueAnymore' }, friendly_id: room.friendly_id }
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns :forbidden if the setting config is "false"' do
        meeting_option = create(:meeting_option, name: 'setting')
        create(:rooms_configuration, meeting_option:, value: 'false')

        put :update, params: { room_setting: { settingName: 'setting', settingValue: 'notFalseAnymore' }, friendly_id: room.friendly_id }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'AuthN' do
      it 'returns :unauthorized response for unauthenticated requests' do
        session[:user_id] = nil

        put :update, params: { friendly_id: room.friendly_id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'returns :bad_request for unfound config' do
      put :update, params: { room_setting: { settingName: '404', settingValue: 'valueOfWhat?' }, friendly_id: room.friendly_id }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :bad_request for invalid params' do
      put :update, params: { not_room_setting: { notSettingName: 'setting', notSettingValue: 'someValue' }, friendly_id: room.friendly_id }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :not_found for unfound room' do
      put :update, params: { room_setting: { settingName: 'setting', settingValue: 'someValue' }, friendly_id: '404' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
