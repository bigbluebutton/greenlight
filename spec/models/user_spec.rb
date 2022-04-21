# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to have_many(:rooms).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_confirmation) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }

    context 'password confirmation' do
      it 'invalidate the record for mismatched password confirmation' do
        user = build(:user, password: 'something', password_confirmation: 'something_else')
        expect(user).to be_invalid
        expect(user.errors.first.details).to eq({ error: :confirmation, attribute: 'Password' })
      end
    end
  end
end
