# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  include Avatarable

  attributes :id, :name, :email, :provider, :language, :avatar, :created_at

  def avatar
    user_avatar(object)
  end

  def created_at
    object.created_at.strftime('%A %B %e, %Y')
  end
end
