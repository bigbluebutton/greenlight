# frozen_string_literal: true

class Recording < ApplicationRecord
  belongs_to :room
  has_one :user, through: :room
  has_many :formats, dependent: :destroy

  validates :name, presence: true
  validates :record_id, presence: true
  validates :visibility, presence: true
  validates :length, presence: true
  validates :participants, presence: true

  scope :with_provider, ->(current_provider) { where(user: { provider: current_provider }) }

  def self.search(input)
    # to prevent showing all recordings with length/participants 0 when input it not 0 (by setting default to -1 instead of 0)
    int_input = if input.to_i.zero? && input != '0'
                  -1
                else
                  input.to_i
                end
    if input
      return joins(:formats).where(
        'recordings.length = :int_input OR recordings.participants = :int_input OR recordings.name ILIKE :input
        OR recordings.visibility ILIKE :input OR formats.recording_type ILIKE :input',
        input: "%#{input}%", int_input:
      ).includes(:formats)
    end

    all.includes(:formats)
  end
end
