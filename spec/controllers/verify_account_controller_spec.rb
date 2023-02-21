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

RSpec.describe Api::V1::VerifyAccountController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST verify_account#create' do
    let(:unverified_user) { create(:user, email: 'unverified@greenlight.com', verified: false) }
    let(:verified_user) { create(:user, email: 'verified@greenlight.com', verified: true) }

    before do
      allow_any_instance_of(User).to receive(:generate_activation_token!).and_return('TOKEN')
      clear_enqueued_jobs
    end

    context 'when account is unverified' do
      it 'generates and sends the activation link' do
        expect_any_instance_of(User).to receive(:generate_activation_token!)

        post :create, params: { user: { id: unverified_user.id } }
        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'activate_account_email',
                                                                                                     'deliver_now', Hash)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when account is verified' do
      it 'returns :ok without generating or sending the activation link' do
        expect_any_instance_of(User).not_to receive(:generate_activation_token!)

        post :create, params: { user: { id: verified_user.id } }
        expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when sending activation email to other users' do
      describe 'with "ManageUsers" permission' do
        before do
          sign_in_user(create(:user, :with_manage_users_permission))
        end

        it 'generates and sends the activation link' do
          expect_any_instance_of(User).to receive(:generate_activation_token!)

          post :create, params: { user: { id: unverified_user.id } }
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'activate_account_email',
                                                                                                       'deliver_now', Hash)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'invalid params' do
      it 'returns :bad_request without generating or sending the activation link' do
        expect_any_instance_of(User).not_to receive(:generate_activation_token!)

        post :create, params: { not_user: { not_id: '12312312313' } }
        expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'unfound emails' do
      it 'returns :ok without generating or sending the activation link' do
        expect_any_instance_of(User).not_to receive(:generate_activation_token!)

        post :create, params: { user: { id: 'not_found_id' } }
        expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST verify_account#activate' do
    let(:valid_params) do
      { token: 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu' }
    end

    it 'activates the found user by digest for valid params' do
      user = create(:user, verified: false)
      allow(User).to receive(:verify_activation_token).with(valid_params[:token]).and_return(user)

      post :activate, params: { user: valid_params }
      expect(response).to have_http_status(:ok)
      expect(user.reload).to be_verified
      expect(user.verification_digest).to be_blank
      expect(user.verification_sent_at).to be_blank
    end

    it 'returns :forbidden for invalid token' do
      allow(User).to receive(:verify_activation_token).and_return(false)

      post :activate, params: { user: valid_params }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns :internal_server_error if unable to invalidate tokens' do
      user = create(:user, verified: false)
      allow(User).to receive(:verify_activation_token).and_return(user)
      allow_any_instance_of(User).to receive(:invalidate_activation_token).and_return(false)

      post :activate, params: { user: valid_params }
      expect(response).to have_http_status(:internal_server_error)
      expect(user.reload).not_to be_verified
    end

    it 'returns :bad_request for missing params' do
      invalid_params = { not_token: '' }

      post :activate, params: { user: invalid_params }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
