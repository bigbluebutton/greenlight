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

RSpec.describe Api::V1::ResetPasswordController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  describe 'POST reset_password#create' do
    before do
      create(:user, email: 'test@greenlight.com')
      allow_any_instance_of(User).to receive(:generate_reset_token!).and_return('TOKEN')
      clear_enqueued_jobs
    end

    it 'generates a unique token, emails and saves its digest for valid emails' do
      post :create, params: { user: { email: 'test@greenlight.com' } }
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'reset_password_email',
                                                                                                   'deliver_now', Hash)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_empty
    end

    it 'returns :bad_request for invalid params' do
      post :create, params: { not_user: { not_email: 'invalid@greenlight.com' } }
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :ok for invalid emails' do
      post :create, params: { user: { email: 'not_a_tester@greenlight.com' } }
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
      expect(response).to have_http_status(:ok)
    end

    it 'returns :ok for external users' do
      create(:user, email: 'user@externals.com', external_id: 'EXTERNAL_ID')
      post :create, params: { user: { email: 'user@externals.com' } }
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST reset_password#reset' do
    let(:valid_params) do
      { new_password: 'Glv3IsAwesome!', token: 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu' }
    end

    it 'updates the found user by digest for valid params' do
      user = create(:user, password: 'Test12345678+')
      allow(User).to receive(:verify_reset_token).with(valid_params[:token]).and_return(user)

      post :reset, params: { user: valid_params }
      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate(valid_params[:new_password])).to be_truthy
      expect(user.reset_digest).to be_blank
      expect(user.reset_sent_at).to be_blank
    end

    it 'returns :forbidden for invalid tokens' do
      user = create(:user, password: 'Test12345678+')
      allow(User).to receive(:verify_reset_token).with(valid_params[:token]).and_return(user)
      allow_any_instance_of(User).to receive(:invalidate_reset_token).and_return(false)

      post :reset, params: { user: valid_params }
      expect(response).to have_http_status(:internal_server_error)
      expect(user.reload.authenticate(valid_params[:new_password])).to be_falsy
    end

    it 'returns :internal_server_errror if unable to invalidate the tokens' do
      allow(User).to receive(:verify_reset_token).and_return(false)

      post :reset, params: { user: valid_params }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns :bad_request for missing params' do
      invalid_params = { new_password: '', token: '' }

      post :reset, params: { user: invalid_params }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST reset_password#verify' do
    let(:valid_params) do
      { token: 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu' }
    end

    it 'returns :ok for valid tokens' do
      user = create(:user)
      allow(User).to receive(:verify_reset_token).with(valid_params[:token]).and_return(user)

      post :verify, params: { user: valid_params }
      expect(response).to have_http_status(:ok)
    end

    it 'returns :forbidden for invalid token' do
      allow(User).to receive(:verify_reset_token).and_return(false)

      post :verify, params: { user: valid_params }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns :bad_request for missing params' do
      post :verify, params: { user: { token: '' } }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
