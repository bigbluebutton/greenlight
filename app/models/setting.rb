# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
