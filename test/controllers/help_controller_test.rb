require 'test_helper'

class HelpControllerTest < ActionDispatch::IntegrationTest
  test "should get getting_started" do
    get help_getting_started_url
    assert_response :success
  end

end
