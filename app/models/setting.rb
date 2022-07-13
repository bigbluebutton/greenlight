# frozen_string_literal: true

class Setting < ApplicationRecord
  has_many :site_settings, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
