# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Format, type: :model do
  describe 'validations' do
    subject { create(:format) }

    it { is_expected.to belong_to(:recording) }
    it { is_expected.to validate_presence_of(:recording_type) }
    it { is_expected.to validate_presence_of(:url) }
  end
end
