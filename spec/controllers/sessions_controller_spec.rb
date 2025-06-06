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
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#create' do
    before do
      allow(controller).to receive(:external_auth?).and_return(false)
    end

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
    end

    it 'logs in with greenlight account before bn account' do
      post :create, params: { session: { email: user.email, password: 'Password1!' } }
      expect(response).to have_http_status(:ok)
      expect(session[:session_token]).to eq(user.reload.session_token)
    end

    it 'logs in with bn account if greenlight account does not exist' do
      user.provider = 'random_provider'
      user.save
      post :create, params: { session: { email: user.email, password: 'Password1!' } }
      expect(response).to have_http_status(:ok)
      expect(session[:session_token]).to eq(super_admin.reload.session_token)
    end

    context 'errors' do
      it 'returns unauthorized if the user is already signed in' do
        sign_in_user(user)

        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'Password1!',
            extend_session: false
          }
        }, as: :json

        expect(response).to be_unauthorized
      end

      it 'returns forbidden if the external auth is enabled' do
        allow(controller).to receive(:external_auth?).and_return(true)

        post :create, params: {
          session: {
            email: 'email@email.com',
            password: 'Password1!',
            extend_session: false
          }
        }, as: :json

        expect(response).to be_forbidden
      end

      it 'returns UnverifiedUser error if the user is not verified' do
        unverified_user = create(:user, password: 'Password1!', verified: false)

        post :create, params: {
          session: {
            email: unverified_user.email,
            password: 'Password1!'
          }
        }

        expect(response.parsed_body['data']).to eq(unverified_user.id)
        expect(response.parsed_body['errors']).to eq('UnverifiedUser')
      end

      it 'returns BannedUser error if the user is banned' do
        banned_user = create(:user, password: 'Password1!', status: :banned)

        post :create, params: {
          session: {
            email: banned_user.email,
            password: 'Password1!'
          }
        }

        expect(response.parsed_body['errors']).to eq('BannedUser')
      end

      it 'returns Pending error if the user is banned' do
        banned_user = create(:user, password: 'Password1!', status: :pending)

        post :create, params: {
          session: {
            email: banned_user.email,
            password: 'Password1!'
          }
        }

        expect(response.parsed_body['errors']).to eq('PendingUser')
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in_user(user)
    end

    it 'signs off the user' do
      delete :destroy

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:session_token]).to be_nil
    end

    context 'external auth' do
      before do
        session[:oidc_id_token] = 'sample_id_token'
        allow(controller).to receive(:external_auth?).and_return(true)
        ENV['OPENID_CONNECT_ISSUER'] = 'https://openid.example'
        ENV['OPENID_CONNECT_LOGOUT_PATH'] = '/protocol/openid-connect/logout'
      end

      after do
        ENV['OPENID_CONNECT_ISSUER'] = nil
        ENV['OPENID_CONNECT_LOGOUT_PATH'] = nil
      end

      it 'returns the OIDC logout url' do
        delete :destroy

        expect(response.parsed_body['data']).to match('protocol/openid-connect/logout')
        expect(response.parsed_body['data']).to match('id_token_hint=sample_id_token')
        expect(response.parsed_body['data']).to match("post_logout_redirect_uri=#{CGI.escape(root_url(success: 'LogoutSuccessful'))}")
      end

      it 'removes both session tokens' do
        delete :destroy

        expect(session[:session_token]).to be_nil
        expect(session[:oidc_id_token]).to be_nil
      end

      context 'LB is set' do
        let!(:role_with_provider_test) { create(:role, provider: 'test-provider') }
        let!(:mt_user) { create(:user, provider: 'test-provider', role: role_with_provider_test) }

        before do
          sign_in_user(mt_user)
          ENV['LOADBALANCER_ENDPOINT'] = 'http://test.com/'
          allow(controller).to receive(:current_provider).and_return('test-provider')
        end

        after do
          ENV['LOADBALANCER_ENDPOINT'] = nil
        end

        it 'returns the OIDC logout url' do
          delete :destroy

          expect(response.parsed_body['data']).to start_with(File.join(ENV.fetch('OPENID_CONNECT_ISSUER', nil), "/#{controller.current_provider}"))
        end
      end
    end
  end
end
