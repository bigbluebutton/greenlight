# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingOption, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:room_meeting_options).dependent(:restrict_with_exception) }
    it { is_expected.to validate_presence_of(:default_value) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
