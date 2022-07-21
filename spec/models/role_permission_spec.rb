# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolePermission, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:permission) }
    it { is_expected.to belong_to(:role) }

    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:provider) }
  end
end
