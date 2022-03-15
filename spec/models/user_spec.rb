# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:provider).case_insensitive }
  end
end
