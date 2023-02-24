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

RSpec.describe Api::V1::Admin::SiteSettingsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_site_settings_permission) { create(:user, :with_manage_site_settings_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_site_settings_permission)
  end

  describe '#index' do
    it 'returns the specified site settings' do
      create(:site_setting, setting: create(:setting, name: 'settingA'), value: 'valueA')
      create(:site_setting, setting: create(:setting, name: 'settingB'), value: 'valueB')
      create(:site_setting, setting: create(:setting, name: 'settingC'), value: 'valueC')

      get :index, params: { names: %w[settingA settingB] }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({
                                                        'settingA' => 'valueA',
                                                        'settingB' => 'valueB'
                                                      })
    end

    context 'user without ManageSiteSettings permission' do
      before do
        sign_in_user(user)
      end

      it 'cant return all the SiteSettings' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    it 'updates the value of SiteSetting' do
      setting = create(:setting, name: 'ShareRooms')
      site_setting = create(:site_setting, setting:, value: false)
      get :update, params: { name: 'ShareRooms', site_setting: { value: true } }
      expect(response).to have_http_status(:ok)
      expect(site_setting.reload.value).to eq('true')
    end

    context 'user without ManageSiteSettings permission' do
      before do
        sign_in_user(user)
      end

      it 'cant update the value of SiteSetting' do
        get :update, params: { name: 'ShareRooms', site_setting: { value: true } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#purge_branding_image' do
    it 'deletes the BrandingImage' do
      setting = create(:setting, name: 'BrandingImage')
      site_setting = create(:site_setting, setting:)

      site_setting.image.attach(io: fixture_file_upload('default-avatar.png'), filename: 'default-avatar.png', content_type: 'image/png')

      expect(site_setting.reload.image).to be_attached
      delete :purge_branding_image
      expect(site_setting.reload.image).not_to be_attached
    end
  end
end
