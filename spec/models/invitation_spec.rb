# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'validations' do
    subject { create(:invitation) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider) }

    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_uniqueness_of(:token) }
  end
end
