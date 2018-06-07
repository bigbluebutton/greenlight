class NotifyUserWaitingJob < ApplicationJob
  queue_as :default

  def perform(room)
    room.notify_waiting
  end
end
