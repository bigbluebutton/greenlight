require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  test "should get not_found" do
    get :not_found
    assert_response :success
  end

  test "should get error" do
    get :error
    assert_response :success
  end

end
