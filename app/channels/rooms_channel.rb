# frozen_string_literal: true

class RoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:friendly_id]}_rooms_channel"
  end

  def unsubscribed; end
end
