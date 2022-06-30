# frozen_string_literal: true

class RecordingSerializer < ApplicationSerializer
  attributes :id, :record_id, :name, :length, :users, :visibility, :created_at

  has_many :formats
end
