# frozen_string_literal: true

module Presentable
  extend ActiveSupport::Concern

  def presentation_name(room)
    return room.presentation.filename if room.presentation.attached?
  end

  def presentation_representation(room)
    return unless room.presentation.attached? && room.presentation.representable?

    rails_representation_url(room.presentation.representation(resize: ['500x500']).processed)
  end
end
