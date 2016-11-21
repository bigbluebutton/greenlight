class JoinMeetingJob < ApplicationJob
  queue_as :default

  def perform(room)
    ActionCable.server.broadcast "#{room}_meeting_updates_channel",
      action: 'moderator_joined',
      moderator: 'joined'
  end
end
