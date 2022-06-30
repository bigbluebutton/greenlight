# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  include Avatarable

  attributes :id, :name, :email, :provider, :language, :avatar

  def avatar
    user_avatar(object)
  end
end
