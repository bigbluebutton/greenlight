# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    subject { create(:role) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:role_permissions).dependent(:destroy) }
  end

  describe '#search' do
    it 'returns the searched roles' do
      searched_roles = [create(:role, name: 'Hashirama Senju'), create(:role, name: 'Tobirama Senju')]
      create_list(:role, 3)
      expect(described_class.search('senju').pluck(:id)).to match_array(searched_roles.pluck(:id))
    end

    it 'returns all roles if input is empty' do
      create_list(:role, 3)
      expect(described_class.search('').pluck(:id)).to match_array(described_class.pluck(:id))
    end
  end

  context 'color attribute' do
    context 'on :create' do
      it 'defaults the color when not provided on :create' do
        allow(SecureRandom).to receive(:hex).and_return('ffffff')
        role = create(:role)
        expect(role.reload.color).to eq('#ffffff')
      end

      it 'overwrites any color value when provided on :create' do
        allow(SecureRandom).to receive(:hex).and_return('ffffff')
        role = build(:role, color: '#HEXTET')
        expect(role).to be_valid
        expect(role.color).to eq('#ffffff')
      end
    end
  end
end
