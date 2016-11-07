class MeetingUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:username]}_meeting_updates_channel"
  end
end
