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

RSpec.describe Api::V1::Admin::InvitationsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  before do
    Faker::Construction.unique.clear
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_users_permission)
  end

  describe 'invitation#index' do
    it 'returns the list of invitations' do
      invitations = [
        create(:invitation, email: 'user@test.com'),
        create(:invitation, email: 'user2@test.com'),
        create(:invitation, email: 'user3@test.com')
      ]

      get :index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].pluck('email')).to match_array(invitations.pluck(:email))
    end

    it 'returns the invitations according to the query' do
      invitations = [
        create(:invitation, email: 'user@test.com'),
        create(:invitation, email: 'user2@test.com')
      ]

      create(:invitation, email: 'user3@not.com')

      get :index, params: { search: 'test.com' }

      expect(response.parsed_body['data'].pluck('email')).to match_array(invitations.pluck(:email))
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        valid_params = { emails: 'user@test.com,user2@test.com,user3@test.com' }
        expect { post :create, params: { invitations: valid_params } }.not_to change(Role, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'invitation#create' do
    it 'returns :ok and creates the invitations' do
      valid_params = { emails: 'user@test.com,user2@test.com,user3@test.com' }
      expect { post :create, params: { invitations: valid_params } }.to change(Invitation, :count).by(3)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['errors']).to be_nil
    end

    it 'emails the invitations to the invited user' do
      valid_params = { emails: 'user@test.com,user2@test.com' }
      post :create, params: { invitations: valid_params }

      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:twice).with('UserMailer', 'invitation_email', 'deliver_now',
                                                                                                    Hash)
    end

    it 'updates the updated_at time if an invite already exists' do
      freeze_time

      inv = create(:invitation, email: 'user@test.com', updated_at: 10.years.ago)
      post :create, params: { invitations: { emails: 'user@test.com' } }
      expect(inv.reload.updated_at).to eq(DateTime.now)
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        valid_params = { emails: 'user@test.com,user2@test.com,user3@test.com' }
        expect { post :create, params: { invitations: valid_params } }.not_to change(Role, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
