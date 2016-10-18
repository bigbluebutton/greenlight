require 'test_helper'

class LandingControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get room" do
    get :room, params: { name: 'user1' }
    assert_response :success
  end

end
