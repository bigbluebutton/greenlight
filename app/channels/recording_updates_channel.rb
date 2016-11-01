class RecordingUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:username]}_recording_updates_channel"
  end
end
