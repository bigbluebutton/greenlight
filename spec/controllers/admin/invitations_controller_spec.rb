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

  describe 'invitation#create' do
    it 'returns :ok and creates the invitations' do
      valid_params = { emails: 'user@test.com,user2@test.com,user3@test.com' }
      expect { post :create, params: { invitations: valid_params } }.to change(Invitation, :count).by(3)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['errors']).to be_nil
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
