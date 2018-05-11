require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @steve = users(:steve)
    @kitchen = rooms(:kitchen)

    @steve.room = @kitchen
  end

  test 'can signin with greenlight account.' do
    post create_session_path, params: {session: {email: @steve.email, password: "steve12345"}}
    
    assert_redirected_to room_path(@steve.room.uid)
    assert @steve.id, session[:user_id]
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
    assert user.id, session[:user_id]
  end

  test 'handles omniauth failure.' do
    OmniAuth.config.on_failure = Proc.new do |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    end

    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

    get "/auth/twitter"

    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]

    assert_no_difference 'User.count' do
      get omniauth_session_path(provider: "twitter")
    end

    assert_redirected_to auth_failure_path(message: "invalid_credentials", strategy: "twitter")
  end

  test 'can logout.' do
    post create_session_path, params: {session: {email: @steve.email, password: "steve12345"}}
    assert @steve.id, session[:user_id]

    get logout_path
    assert_not_equal @steve.id, session[:user_id]
  end
end
