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
    if input
      return joins(:formats).where('recordings.name ILIKE :input OR recordings.visibility ILIKE :input OR formats.recording_type ILIKE :input',
                                   input: "%#{input}%").includes(:formats)
    end

    all.includes(:formats)
  end
end
