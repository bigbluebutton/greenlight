# frozen_string_literal: true

class ApplicationSerializer < ActiveModel::Serializer
  def created_at
    object.created_at.strftime('%A %B %e, %Y %l:%M%P')
  end

  def updated_at
    object.updated_at.strftime('%A %B %e, %Y %l:%M%P')
  end
end
