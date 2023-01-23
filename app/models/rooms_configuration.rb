# frozen_string_literal: true

class RoomsConfiguration < ApplicationRecord
  belongs_to :meeting_option
  validates :provider, presence: true
  # 'option': 'default': Optional but defaulted to true, 'optional' Optional but defaulted to false, 'true': Force enabled, 'false': Disabled.
  validates :value, inclusion: { in: %w[default optional true false] }
  validates :meeting_option_id, uniqueness: { scope: :provider }

  delegate :name, to: :meeting_option
end
