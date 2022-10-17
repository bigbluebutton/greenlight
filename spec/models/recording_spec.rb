# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recording, type: :model do
  describe 'validations' do
    subject { create(:recording) }

    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:formats).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:record_id) }
    it { is_expected.to validate_presence_of(:visibility) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:participants) }
  end

  describe 'scopes' do
    context 'with_provider' do
      it 'only includes users with the specified provider' do
        room1 = create(:room, user: create(:user, provider: 'greenlight'))
        role_with_provider_test = create(:role, provider: 'test')
        room2 = create(:room, user: create(:user, provider: 'test', role: role_with_provider_test))

        create_list(:recording, 5, room: room1)
        create_list(:recording, 5, room: room2)

        recs = described_class.includes(:user).with_provider('greenlight')
        expect(recs.count).to eq(5)
        expect(recs.pluck(:provider).uniq).to eq(['greenlight'])
      end
    end
  end

  describe '#search' do
    it 'returns the searched recordings' do
      recording1 = create(:recording, name: 'Greenlight 101')
      recording2 = create(:recording, name: 'Greenlight 201')
      recording3 = create(:recording, name: 'Greenlight 301')
      create_list(:recording, 5)
      expect(described_class.all.search('greenlight').pluck(:name)).to match_array([recording1.name, recording2.name, recording3.name])
    end

    it 'returns all recordings if input is empty' do
      create_list(:recording, 5)
      expect(described_class.all.search('').pluck(:id)).to match_array(described_class.all.pluck(:id))
    end
  end
end
