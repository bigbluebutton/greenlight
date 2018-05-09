require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
      name: "Example User",
      username: "Username",
      provider: "greenlight",
      email: "user@example.com",
      password: "example",
      password_confirmation: "example"
    )

    @room = Room.new(
      user: @user
    )
  end

  test "#owned_by? should identify correct owner." do
    assert @room.owned_by?(@user)
  end

  test "#owned_by? should identify incorrect owner." do
    diff_user = User.new(
      name: "Different User",
      username: "Diffname",
      provider: "greenlight",
      email: "diff@example.com",
    )
    
    assert_not @room.owned_by?(diff_user)
  end

  test "should set uid on creation." do
    @room.save
    assert @room.uid
  end
end
