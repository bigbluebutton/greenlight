# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:role_permissions).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:name) }
  end
end
