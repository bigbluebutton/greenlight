# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern

  def user_avatar(user)
    return url_for(user.avatar) if user.avatar.attached?

    ActionController::Base.helpers.image_url('default-avatar.png')
  end
end
