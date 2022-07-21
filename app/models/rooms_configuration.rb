# frozen_string_literal: true

class RoomsConfiguration < ApplicationRecord
  belongs_to :meeting_option
  validates :provider, presence: true
  # 'option': Optional config, 'true': Force enabled, 'false': Disabled.
  validates :value, inclusion: { in: %w[optional true false] }
  validates :meeting_option_id, uniqueness: { scope: :provider }

  delegate :name, to: :meeting_option
end
