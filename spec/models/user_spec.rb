# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to belong_to(:role) }

    it { is_expected.to have_many(:rooms).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_presence_of(:email) }

    # TODO: samuel - need to find a solution for this
    # it { is_expected.to validate_presence_of(:password_confirmation) }

    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }

    context 'password confirmation' do
      it 'invalidate the record for mismatched password confirmation' do
        user = build(:user, password: 'something', password_confirmation: 'something_else')
        expect(user).to be_invalid
        expect(user.errors.first.details).to eq({ error: :confirmation, attribute: 'Password' })
      end
    end

    describe '#search' do
      it 'returns the searched users' do
        searched_users = create_list(:user, 5, name: 'Jane Doe')
        create_list(:user, 5)
        expect(described_class.all.search('jane doe').pluck(:id)).to match_array(searched_users.pluck(:id))
      end

      it 'returns all users if input is empty' do
        create_list(:user, 10)
        expect(described_class.all.search('').pluck(:id)).to match_array(described_class.all.pluck(:id))
      end
    end
  end
end
