# frozen_string_literal: true

class Recording < ApplicationRecord
  belongs_to :room

  validates :name, presence: true
  validates :record_id, presence: true
end
