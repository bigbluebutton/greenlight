# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require 'test_helper'

class LandingControllerTest < ActionController::TestCase

  setup do
    @meeting_id = 'test_id'
    @user = users :user1
  end

  test "should get index" do
    Rails.configuration.disable_guest_access = false
    get :index, params: {resource: 'meetings'}
    assert_response :success
  end

  test "should redirect to guest from index" do
    Rails.configuration.disable_guest_access = true
    get :index, params: {resource: 'meetings'}
    assert_redirected_to guest_path
  end

  test "should get meeting" do
    Rails.configuration.disable_guest_access = false
    get :resource, params: { id: @meeting_id, resource: 'meetings' }
    assert_response :success
  end

  test "should redirect to guest from meeting" do
    Rails.configuration.disable_guest_access = true
    get :index, params: {resource: 'meetings'}
    assert_redirected_to guest_path
  end

  test "should get room" do
    get :resource, params: { id: @user.encrypted_id, resource: 'rooms' }
    assert_response :success
  end

  test "should get meeting room" do
    get :resource, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms' }
    assert_response :success
  end

  test "should not get room for invalid user" do
    get :resource, params: { room_id: 'invalid id', id: @meeting_id, resource: 'rooms' }
    assert_response :redirect
  end

  test "should get wait for moderator" do
    get :wait_for_moderator, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms' }
    assert_response :success
  end

  test "should get session status refresh" do
    get :session_status_refresh, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms' }
    assert_response :success
  end

  test "should fallback to en-US locale if locale is en" do
    Rails.configuration.disable_guest_access = false
    request.headers["Accept-Language"] = 'en'
    get :index, params: {resource: 'meetings'}
    assert_response :success
    assert css_select('html').attribute('lang').value, 'en'
  end

end
