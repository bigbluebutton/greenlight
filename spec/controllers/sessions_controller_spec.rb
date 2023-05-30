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

RSpec.describe Api::V1::SessionsController, type: :controller do
  let!(:user) { create(:user, email: 'email@email.com', password: 'Password1!', password_confirmation: 'Password1!') }
  let!(:super_admin_role) { create(:role, :with_super_admin) }
  let!(:super_admin) { create(:user, role: super_admin_role, email: 'email@email.com', provider: 'bn') }

  before do
    allow(controller).to receive(:external_authn_enabled?).and_return(false)

    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#create' do
    context 'Valid credentials' do
      it 'creates a regular session if the remember me checkbox is not selected' do
        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'Password1!',
            extend_session: false
          }
        }, as: :json

        expect(cookies.encrypted[:_extended_session]).to be_nil
        expect(session[:session_token]).to eq(user.reload.session_token)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['errors']).to be_blank
        expect(JSON.parse(response.body)['data']).not_to be_blank
      end

      it 'creates an extended session if the remember me checkbox is selected' do
        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'Password1!',
            extend_session: true
          }
        }, as: :json

        expect(cookies.encrypted[:_extended_session]['session_token']).to eq(user.reload.session_token)
        expect(session[:session_token]).to eq(user.session_token)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['errors']).to be_blank
        expect(JSON.parse(response.body)['data']).not_to be_blank
      end

      it 'returns UnverifiedUser error if the user is not verified' do
        unverified_user = create(:user, password: 'Password1!', verified: false)

        post :create, params: {
          session: {
            email: unverified_user.email,
            password: 'Password1!'
          }
        }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['data']).to be_blank
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:unverified_user])
      end

      it 'returns BannedUser error if the user is banned' do
        banned_user = create(:user, password: 'Password1!', status: :banned)

        post :create, params: {
          session: {
            email: banned_user.email,
            password: 'Password1!'
          }
        }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['data']).to be_blank
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:banned_user])
      end

      it 'returns Pending error if the user is banned' do
        banned_user = create(:user, password: 'Password1!', status: :pending)

        post :create, params: {
          session: {
            email: banned_user.email,
            password: 'Password1!'
          }
        }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['data']).to be_blank
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:pending_user])
      end

      context 'Provider' do
        it 'logs in with greenlight account before bn account' do
          post :create, params: { session: { email: user.email, password: 'Password1!' } }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['data']).not_to be_blank
          expect(JSON.parse(response.body)['errors']).to be_blank
          expect(session[:session_token]).to eq(user.reload.session_token)
        end

        describe 'bn account' do
          before do
            user.provider = 'random_provider'
            user.save
          end

          it 'logs in with bn account if greenlight account does not exist' do
            post :create, params: { session: { email: user.email, password: 'Password1!' } }
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)['data']).not_to be_blank
            expect(JSON.parse(response.body)['errors']).to be_blank
            expect(session[:session_token]).to eq(super_admin.reload.session_token)
          end
        end
      end
    end

    context 'Invalid credentials' do
      it 'returns :bad_request and RecordInvalid error without creating a session' do
        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'WrongPassword1!',
            extend_session: false
          }
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(cookies.encrypted[:_extended_session]).to be_nil
        expect(session[:session_token]).to be_nil
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:record_invalid])
        expect(JSON.parse(response.body)['data']).to be_blank
      end
    end

    context 'Inexistent account' do
      it 'returns :bad_request and RecordInvalid error without creating a session' do
        post :create, params: {
          session: {
            email: 'null@ghosts.void',
            password: 'Password1!',
            extend_session: false
          }
        }, as: :json

        expect(cookies.encrypted[:_extended_session]).to be_nil
        expect(session[:session_token]).to be_nil
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:record_invalid])
        expect(JSON.parse(response.body)['data']).to be_blank
      end
    end

    context 'External AuthN enabled' do
      before do
        allow(controller).to receive(:external_authn_enabled?).and_return(true)
      end

      describe 'greenlight account signin' do
        it 'returns :forbidden without signin the user' do
          post :create, params: { session: { email: user.email, password: 'Password1!' } }

          expect(response).to have_http_status(:forbidden)
          expect(JSON.parse(response.body)['data']).to be_blank
          expect(JSON.parse(response.body)['errors']).not_to be_nil
        end
      end

      describe 'bn account signin' do
        before do
          user.provider = 'random_provider'
          user.save
        end

        it 'returns :ok while signin the user if bn account' do
          post :create, params: { session: { email: super_admin.email, password: 'Password1!' } }

          expect(response).to have_http_status(:ok)
          expect(session[:session_token]).to eq(super_admin.reload.session_token)
          expect(JSON.parse(response.body)['data']).not_to be_blank
          expect(JSON.parse(response.body)['errors']).to be_blank
        end
      end
    end

    context 'Already logged in' do
      let(:signed_in_user) { create(:user) }

      before do
        sign_in_user signed_in_user
      end

      it 'returns :unauthorized and does not sign in the user' do
        expect(session[:session_token]).to eq(signed_in_user.reload.session_token)

        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'Password1!',
            extend_session: false
          }
        }, as: :json

        expect(session[:session_token]).not_to eq(user.reload.session_token)
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).not_to be_nil
        expect(JSON.parse(response.body)['data']).to be_blank
      end
    end
  end

  describe '#destroy' do
    it 'signs off the user' do
      sign_in_user(user)

      delete :destroy

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:session_token]).to be_nil
    end
  end
end
