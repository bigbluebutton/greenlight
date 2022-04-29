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
    before do
      create_list :meeting_option, 5
    end

    describe '#create_default_meeting_options!' do
      it 'fetches and creates all saved none password meeting options for the created room with default values' do
        room = create(:room)
        default_meeting_options_ids_values_hash = MeetingOption.pluck(:id, :default_value).to_h
        room_meeting_option_ids_values_hash = room.room_meeting_options.pluck(:meeting_option_id, :value).to_h
        expect(room_meeting_option_ids_values_hash).to eq(default_meeting_options_ids_values_hash)
      end
    end

    describe '#set_meeting_passwords' do
      before do
        create :meeting_option, name: 'somePW', default_value: ''
        create :meeting_option, name: 'someOtherPW', default_value: ''
      end

      it 'creates and sets the password meeting options and the rest of the default options for the created room' do
        room = create(:room)
        expect(room.room_meeting_options.count).to eq(MeetingOption.count)

        password_option_ids_default_values_hash = MeetingOption.where('name LIKE ?', '%PW').pluck(:id, :default_value).to_h
        room_meeting_options_ids_values = room.room_meeting_options.pluck(:meeting_option_id, :value).to_h

        password_option_ids_default_values_hash&.each_key do |id|
          expect(room_meeting_options_ids_values[id]).not_to eq(password_option_ids_default_values_hash[id])
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
