# frozen_string_literal: true

require 'rails_helper'

describe MeetingConfig, type: :service do
  describe '#create_meeting_options!' do
    let(:room) { create :room }
    let(:existent_options) do
      {
        option: 'value',
        option1: 'value1'
      }
    end

    let(:inexistent_options) do
      {
        something: 'something',
        something1: 'something1'
      }
    end

    before do
      create :meeting_option, name: 'option'
      create :meeting_option, name: 'option1'
      create :meeting_option, name: 'option2'
    end

    it 'creates room_meeting_options for existent meeting_options' do
      expect(MeetingOption.count).not_to be_zero
      meeting_config = described_class.new(room:, options: existent_options)
      expect { meeting_config.create_meeting_options! }.to change { room.room_meeting_options.count }.from(0)
    end

    it 'filters out any inexistent room_meeting_options in the list of public_options' do
      expect(MeetingOption.count).not_to be_zero
      inexistent_options_string_keys = inexistent_options.keys.map(&:to_s)
      expect(MeetingOption.public_option_names & inexistent_options_string_keys).to be_empty
      meeting_config = described_class.new(room:, options: inexistent_options)
      expect { meeting_config.create_meeting_options! }.not_to(change { room.room_meeting_options.count })
    end
  end

  describe '#MeetingConfig.option_names' do
    before { allow(MeetingOption).to receive(:public_option_names).and_return(%w[option option1 option2]) }

    it 'returns a joined array of MeetingOption.public_option_names and MeetingConfig::UI_OPTION_NAMES' do
      expect(MeetingOption).to receive(:public_option_names)
      option_names = MeetingOption.public_option_names + described_class::UI_OPTION_NAMES
      expect(described_class.option_names - option_names).to be_empty
    end
  end
end
