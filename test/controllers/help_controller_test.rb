require 'test_helper'

class HelpControllerTest < ActionDispatch::IntegrationTest
  test "should get getting_started" do
    get help_url
    assert_response :success
  end

end
