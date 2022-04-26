# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'before_validations' do
    let!(:room) { create(:room) }

    describe '#set_friendly_id' do
      it 'sets a rooms friendly_id before creating' do
        expect(room.friendly_id).to be_present
      end

      it 'prevents duplicate friendly_ids' do
        duplicate_room = create(:room)
        expect { duplicate_room.friendly_id = room.friendly_id }.to change { duplicate_room.valid? }.to false
      end
    end

    describe '#set_meeting_id' do
      it 'sets a rooms meeting_id before creating' do
        expect(room.meeting_id).to be_present
      end

      it 'prevents duplicate meeting_ids' do
        duplicate_room = create(:room)
        expect { duplicate_room.meeting_id = room.meeting_id }.to change { duplicate_room.valid? }.to false
      end
    end
  end

  describe 'after_create' do
    let(:room) { create(:room) }

    before do
      create :meeting_option, name: 'attendeePW', default_value: ''
      create :meeting_option, name: 'moderatorPW', default_value: ''
    end

    describe '#set_passwords' do
      it 'creates and sets the moderatorPW and attendeePW meeting options for the created room' do
        password_option_ids = MeetingOption.password_option_ids
        room_meeting_options_ids_values = room.room_meeting_options.pluck(:meeting_option_id, :value).to_h

        password_option_ids&.each do |id|
          expect(room_meeting_options_ids_values[id]).to be_present
        end
      end
    end
  end

  describe 'validations' do
    subject { create(:room) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recordings).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
    # Can't test validation on friendly_id and meeting_id due to before_validations
  end
end
