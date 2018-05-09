require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.new(
      name: "Example User",
      username: "Username",
      provider: "greenlight",
      email: "user@example.com",
      password: "example",
      password_confirmation: "example"
    )

    @user.save!
  end

  test 'can signin with greenlight account.' do
    post create_session_path, params: {session: {email: @user.email, password: @user.password}}

    assert_redirected_to room_path(@user.room.uid)
    assert @user.id, session[:user_id]
  end

  test 'can signup for greenlight account.' do

  end

  test 'can signup/login with omniauth.' do
    email = "omniauth@test.com"
    uid = "123456789"

    OmniAuth.config.add_mock(:twitter, {
      provider: "twitter",
      uid: uid,
      info: {
        email: email,
        name: "Omni User",
        nickname: "username"
      }
    })

    get "/auth/twitter"

    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
    get omniauth_session_path(provider: "twitter")

    user = User.find_by(email: email, uid: uid)

    assert_not_nil user
    assert_redirected_to room_path(user.room.uid)
    assert @user.id, session[:user_id]
  end

  test 'can logout.' do
    post create_session_path, params: {session: {email: @user.email, password: @user.password}}
    assert @user.id, session[:user_id]

    get logout_path
    assert_not_equal @user.id, session[:user_id]
  end

end
