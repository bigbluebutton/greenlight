# frozen_string_literal: true

class Recording < ApplicationRecord
  belongs_to :room
  has_many :formats, dependent: :destroy

  validates :name, presence: true
  validates :record_id, presence: true
  validates :visibility, presence: true
  validates :length, presence: true
  validates :users, presence: true

  def self.search(input)
    return where('recordings.name ILIKE ?', "%#{input}%").includes(:formats) if input

    all.includes(:formats)
  end
end
