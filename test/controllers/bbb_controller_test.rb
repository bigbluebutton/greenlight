require 'test_helper'

class BbbControllerTest < ActionDispatch::IntegrationTest
  test "should get join" do
    get bbb_join_url
    assert_response :success
  end

  test "should get end" do
    get bbb_end_url
    assert_response :success
  end

end
