class RecordingUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:encrypted_id]}_recording_updates_channel"
  end
end
