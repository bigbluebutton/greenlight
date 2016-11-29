require 'test_helper'

class LandingControllerTest < ActionController::TestCase

  setup do
    @meeting_id = rand 100000000..999999999
    @user = users :user1
  end

  test "should get index" do
    get :index, params: {resource: 'meetings'}
    assert_response :success
  end

  test "should get meeting" do
    get :resource, params: { id: @meeting_id, resource: 'meetings' }
    assert_response :success
  end

  test "should get room" do
    get :resource, params: { id: @user.encrypted_id, resource: 'rooms' }
    assert_response :success
  end

  test "should get wait for moderator" do
    get :wait_for_moderator, params: { id: @user.encrypted_id, resource: 'rooms' }
    assert_response :success
  end

  test "should get session status refresh" do
    get :wait_for_moderator, params: { id: @user.encrypted_id, resource: 'rooms' }
    assert_response :success
  end

end
