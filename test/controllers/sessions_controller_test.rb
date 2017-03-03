require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = users :user1
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect to home on auth failture" do
    get "auth_failure"
    assert_redirected_to root_path
  end

  test "should not create session without omniauth env set" do
    post :create, params: {provider: 'google'}
    assert_redirected_to root_path
  end

  test "should create session and user" do
    provider = 'google'
    email = 'new_user@email.com'
    request.env['omniauth.auth'] = {'uid' => 'uid', 'provider' => provider,
      'info' => {'name' => 'name', 'email' => email}}

    post :create, params: {provider: provider}

    new_user = User.find_by email: email

    assert_not_nil new_user
    assert_redirected_to meeting_room_path(id: new_user.encrypted_id, resource: 'rooms')
    assert_equal new_user.id, session[:user_id]
  end

  test "should destroy current session" do
    session[:user_id] = @user.id
    get :destroy
    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end
