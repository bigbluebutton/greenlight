# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    subject { create(:role) }

    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end
end
