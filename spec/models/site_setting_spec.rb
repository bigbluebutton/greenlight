# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteSetting, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:setting) }
    it { is_expected.to validate_presence_of(:provider) }
  end
end
