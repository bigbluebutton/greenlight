require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test 'can signup for greenlight account.' do
    post signup_path, params: {
      user: {
        name: "Greenlight User",
        username: "greenlight_user",
        email: "greenlight@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    user = User.find_by(email: "greenlight@example.com")

    assert_not_nil user
    assert_redirected_to room_path(user.room.uid)
    assert user.id, session[:user_id]
  end
end
