# frozen_string_literal: true

class RecordingSerializer < ApplicationSerializer
  attributes :id, :record_id, :name, :length, :participants, :visibility, :protectable, :created_at

  has_many :formats

  def formats
    object.formats.order(:recording_type)
  end
end
