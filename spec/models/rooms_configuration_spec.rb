# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsConfiguration, type: :model do
  describe 'validations' do
    subject { create(:rooms_configuration) }

    it { is_expected.to belong_to(:meeting_option) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_inclusion_of(:value).in_array(%w[optional true false]) }
    it { is_expected.to validate_uniqueness_of(:meeting_option_id).scoped_to(:provider).case_insensitive }
    it { is_expected.to delegate_method(:name).to(:meeting_option) }
  end
end
