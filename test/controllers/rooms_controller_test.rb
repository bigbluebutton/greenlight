require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @steve = users(:steve)
    @mark = users(:mark)

    @kitchen = rooms(:kitchen)
    @garage = rooms(:garage)
  end

  test 'should redirect to root if not logged in.' do
    get room_path(@kitchen.uid)

    assert_redirected_to root_path
  end

  test 'should redirect to correct room if incorrect room.' do
    post create_session_path, params: {session: {email: @mark.email, password: "mark12345"}}
    get room_path(@kitchen.uid)

    assert_redirected_to room_path(@garage.uid)
  end

  test 'should render room if user is owner.' do
    post create_session_path, params: {session: {email: @steve.email, password: "steve12345"}}
    get room_path(@kitchen.uid)

    assert_response :success
  end
end
