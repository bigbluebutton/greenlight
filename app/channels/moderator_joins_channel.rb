class ModeratorJoinsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "moderator_#{params[:username]}_join_channel"
  end
end
