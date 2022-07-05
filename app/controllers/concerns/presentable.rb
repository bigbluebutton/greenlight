# frozen_string_literal: true

module Presentable
  extend ActiveSupport::Concern

  def presentation_file_name(room)
    return room.presentation.filename if room.presentation.attached?
  end

  def presentation_thumbnail(room)
    return if !room.presentation.attached? || !room.presentation.representable?

    view_context.rails_representation_url(room.presentation.representation(resize: ['225x125']).processed)
  end
end
