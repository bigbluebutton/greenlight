# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomMeetingOption, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:meeting_option) }
    it { is_expected.to delegate_method(:name).to(:meeting_option) }
  end
end
