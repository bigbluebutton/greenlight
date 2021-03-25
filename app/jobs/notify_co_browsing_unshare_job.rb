class NotifyCoBrowsingUnshareJob < ApplicationJob
  queue_as :default

  def perform(room)
    room.notify_co_browsing_unshare
  end
end