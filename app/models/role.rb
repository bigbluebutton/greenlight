# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true
end
