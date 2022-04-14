# frozen_string_literal: true

class Format < ApplicationRecord
  belongs_to :recording

  validates :recording_type, presence: true
  validates :url, presence: true
end
