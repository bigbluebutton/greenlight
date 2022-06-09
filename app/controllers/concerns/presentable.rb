# frozen_string_literal: true

module Presentable
  extend ActiveSupport::Concern

  def room_presentation(room)
    return url_for(room.presentation) if room.presentation.attached?
  end
end
