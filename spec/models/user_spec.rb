# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create_room' do
    it 'creates a room for a newly created user' do
      expect { create(:user) }
        .to change(described_class, :count).by(1).and change(Room, :count).by(1)
    end
  end

  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to have_many(:rooms) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }
  end
end
