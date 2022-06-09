# frozen_string_literal: true

module Presentation
  extend ActiveSupport::Concern

  def room_presentation(room)
    return url_for(room.presentation) if room.presentation.attached?
  end
end
