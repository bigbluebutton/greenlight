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

RSpec.describe Api::V1::LocalesController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#show' do
    it 'returns the correct language file' do
      get :show, params: { name: 'en' }
      expect(response).to redirect_to(ActionController::Base.helpers.asset_path('en.json'))
    end

    it 'returns the correct dialect file' do
      get :show, params: { name: 'ko_KR' }
      expect(response).to redirect_to(ActionController::Base.helpers.asset_path('ko_KR.json'))
    end

    it 'returns the dialect language file if the regular language doesnt exist' do
      get :show, params: { name: 'pl' }
      expect(response).to redirect_to(ActionController::Base.helpers.asset_path('pl_PL.json'))
    end

    it 'returns not_acceptable if the language doesnt exist' do
      get :show, params: { name: 'invalid' }
      expect(response).to have_http_status(:not_acceptable)
    end
  end
end
