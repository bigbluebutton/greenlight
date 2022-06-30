# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true

  before_validation :set_random_color, on: :create

  def self.search(input)
    return where('name ILIKE ?', "%#{input}%") if input

    all
  end

  private

  def set_random_color
    self.color = "##{SecureRandom.hex(3)}"
  end
end
