# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    subject { create(:role) }

    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }

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
end
