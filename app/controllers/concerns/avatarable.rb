# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern

  def user_avatar(user)
    return view_context.url_for(user.avatar) if user.avatar.attached?

    view_context.image_url('default-avatar.png')
  end
end
