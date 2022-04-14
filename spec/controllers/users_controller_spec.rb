# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  # TODO - samuel: does this belong in Controller spec? Or Model?
  describe 'POST users#create' do
    it 'adds greenlight as provider on creation' do
      user = create(:user)
      expect(user).to have_attributes(provider: 'greenlight')
    end
  end

  describe 'POST users#update' do
    it 'allows user to edit his name' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { name: 'New Name' } }
      Rails.logger.debug "Reason of rollback: #{user.errors.full_messages}"
      expect(response).to have_http_status(:ok)
      expect(user.name).to eql('New Name')
    end
  end
end
