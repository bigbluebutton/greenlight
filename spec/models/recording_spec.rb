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

RSpec.describe Recording, type: :model do
  describe 'Constants' do
    context 'VISIBILITES' do
      it 'matches certain map' do
        expect(Recording::VISIBILITIES).to eq({
                                                published: 'Published',
                                                unpublished: 'Unpublished',
                                                protected: 'Protected',
                                                public: 'Public',
                                                public_protected: 'Public/Protected'
                                              })
      end
    end
  end

  describe 'validations' do
    subject { create(:recording) }

    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:formats).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:record_id) }
    it { is_expected.to validate_presence_of(:visibility) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_presence_of(:participants) }
    it { is_expected.to validate_inclusion_of(:visibility).in_array(Recording::VISIBILITIES.values) }
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
