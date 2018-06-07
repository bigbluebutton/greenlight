class WaitingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:uid]}_waiting_channel"
  end
end
