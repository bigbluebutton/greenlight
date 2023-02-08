# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  include Avatarable

  attributes :id, :name, :email, :provider, :language, :avatar, :verified, :created_at

  belongs_to :role

  def language
    object.language.tr('_', '-')
  end

  def avatar
    user_avatar(object)
  end
end
