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

class BbbControllerTest < ActionController::TestCase
  include BbbApi

  setup do
    @meeting_id = 'test_id'
    @user = users :user1
    @name = 'test_name'
    @recording = 'test_recording'
  end

  test "should get join URL from join for meeting" do
    BbbController.any_instance.expects(:bbb_join_url)
      .with() do |token, full_name, opts|
        token == @meeting_id && full_name == @name && opts[:user_is_moderator]
      end.returns(success_join_res('correct_url')).once

    get :join, params: { id: @meeting_id, resource: 'meetings', name: @name }
    assert_response :success

    result = JSON.parse(response.body).deep_symbolize_keys
    assert_equal 'correct_url', result[:response][:join_url]
  end

  test "should get join URL from join for authenticated meeting" do
    login @user

    BbbController.any_instance.expects(:bbb_join_url)
      .with() do |token, full_name, opts|
        token == meeting_token(@user, @meeting_id) && opts[:wait_for_moderator] && opts[:user_is_moderator] && opts[:meeting_recorded]
      end.returns(success_join_res('correct_url')).once

    get :join, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms', name: @name }
    assert_response :success
  end

  test "should wati for moderator on join for authenticated meeting when not room owner" do
    BbbController.any_instance.expects(:bbb_join_url)
      .with() do |token, full_name, opts|
        opts[:wait_for_moderator] && !opts[:user_is_moderator]
      end.returns(success_join_res('correct_url')).once

    get :join, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms', name: @name }
    assert_response :success
  end

  test "should end meeting" do
    login @user

    BbbController.any_instance.expects(:bbb_end_meeting)
      .with() do |token|
        token == meeting_token(@user, @meeting_id)
      end.returns({status: :ok}).once

    get :end, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms' }
    assert_response :success
  end

  test "should not end meeting for unauthorized user" do
    login users :user2

    get :end, params: { room_id: @user.encrypted_id, id: @meeting_id, resource: 'rooms' }
    assert_response :unauthorized
  end

  test "should get recordings" do

    BbbController.any_instance.expects(:bbb_get_recordings)
      .returns({status: :ok, recordings: []}).once

    get :recordings, params: { room_id: @user.encrypted_id, resource: 'rooms' }
    assert_response :success
  end

  test "should update recording" do
    login @user

    BbbController.any_instance.expects(:bbb_get_recordings)
      .returns({status: :ok, recordings: [{recordID: @recording}]}).once

    BbbController.any_instance.expects(:bbb_update_recordings)
      .returns({status: :ok}).once

    patch :update_recordings, params: { room_id: @user.encrypted_id, resource: 'rooms', record_id: @recording }
    assert_response :success
  end

  test "should delete recording" do
    login @user

    BbbController.any_instance.expects(:bbb_get_recordings)
      .returns({status: :ok, recordings: [{recordID: @recording}]}).at_least_once

    BbbController.any_instance.expects(:bbb_delete_recordings)
      .returns({status: :ok}).once

    delete :delete_recordings, params: { room_id: @user.encrypted_id, resource: 'rooms', record_id: @recording }
    assert_response :success
  end

  test "should not delete recording if unauthorized" do
    login users :user2

    BbbController.any_instance.expects(:bbb_get_recordings)
      .returns({status: :ok, recordings: [{recordID: @recording}]}).at_least_once

    BbbController.any_instance.expects(:bbb_delete_recordings)
      .returns({status: :ok}).once

    delete :delete_recordings, params: { room_id: @user.encrypted_id, resource: 'rooms', record_id: @recording }
    assert_response :unauthorized
  end

  test "should not delete recording if not owner" do
    login @user

    BbbController.any_instance.expects(:bbb_get_recordings)
      .returns({status: :ok, recordings: []}).once

    BbbController.any_instance.expects(:bbb_update_recordings)
      .returns({status: :ok}).once

    patch :delete_recordings, params: { room_id: @user.encrypted_id, resource: 'rooms', record_id: @recording }
    assert_response :not_found
  end

  test "should return success on invalid checksum" do

    BbbController.any_instance.expects(:treat_callback_event).never

    post :callback, params: { room_id: @user.encrypted_id, resource: 'rooms', id: @meeting_id, event: {} }
    assert_response :success
  end

  # TODO fix this test
  # test "should send notification on valid callback" do
  #
  #   BbbController.any_instance.expects(:treat_callback_event).once
  #
  #   BbbController.any_instance.expects(:validate_checksum)
  #     .returns(true).once
  #
  #   post :callback, params: { room_id: @user.encrypted_id, resource: 'rooms', id: @meeting_id, event: {} }
  #   assert_response :success
  # end

  private

  def meeting_token(user, id)
    "#{user.encrypted_id}-#{id}"
  end

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end
end
