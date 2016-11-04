class MeetingUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:encrypted_id]}_meeting_updates_channel"
  end
end
