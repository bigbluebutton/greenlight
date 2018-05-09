require 'test_helper'

class MeetingTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
      name: "Example User",
      username: "Username",
      provider: "greenlight",
      email: "user@example.com",
      password: "example",
      password_confirmation: "example"
    )

    @room = Room.new(user: @user)
    
    @meeting = Meeting.new(
      name: "Test Meeting",
      room: @room
    )
  end

  test "name should be present." do
    @meeting.name = nil
    assert_not @meeting.valid?
  end

  test "should set uid on creation." do
    @meeting.save
    assert @meeting.uid
  end
end
