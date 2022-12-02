# frozen_string_literal: true
class InstantRoomsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*room)
    InstantRoom.delete_by(id: room.id)
  end
end
