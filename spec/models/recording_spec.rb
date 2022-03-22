# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recording, type: :model do
  describe 'validations' do
    subject { create(:recording) }

    it { is_expected.to belong_to(:room) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:record_id) }
  end
end
