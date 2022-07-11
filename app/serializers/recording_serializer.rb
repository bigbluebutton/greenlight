# frozen_string_literal: true

class RecordingSerializer < ApplicationSerializer
  attributes :id, :record_id, :name, :length, :users, :visibility, :protectable, :created_at

  has_many :formats
end
