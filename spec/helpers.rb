# frozen_string_literal: true

module Helpers
  def sign_in_user(user)
    session[:session_token] = user.session_token
  end

  # Populate the permissions that are enabled by default on the 'User' role and custom Roles
  def create_default_permissions
    create(:permission, name: 'CreateRoom')
    create(:permission, name: 'CanRecord')
    create(:permission, name: 'SharedList')
    create(:permission, name: 'RoomLimit')
  end
end
