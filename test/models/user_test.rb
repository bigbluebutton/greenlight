require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @steve = users(:steve)
  end

  test "should be valid." do
    assert @steve.valid?
  end

  test "name should be present." do
    @steve.name = nil
    assert_not @steve.valid?
  end

  test "should allow nil email." do
    @steve.email = nil
    assert @steve.valid?
  end

  test "username should be present." do
    @steve.username = nil
    assert_not @steve.valid?
  end

  test "provider should be present." do
    @steve.provider = nil
    assert_not @steve.valid?
  end

  test "should allow nil uid." do
    @steve.uid = nil
    assert @steve.valid?
  end

  test "should allow nil password." do
    @steve.password = @steve.password_confirmation = nil
    assert @steve.valid?
  end

  test "password should be longer than 6 characters if it exists." do
    @steve.password = "short"
    assert_not @steve.valid?
  end

  test "should create user from omniauth" do
    auth = {
      "uid" => "123456789",
      "provider" => "twitter",
      "info" => {
        "name" => "Test Name",
        "nickname" => "username",
        "email" => "test@example.com"
      }
    }

    assert_difference 'User.count' do
      User.from_omniauth(auth)
    end

    user = User.find_by(uid: auth["uid"], provider: auth["provider"])

    assert user.username, auth["info"]["nickname"]
    assert user.name, auth["info"]["name"]
  end

  test "email addresses should be saved as lower-case." do
    mixed_case = "ExAmPlE@eXaMpLe.CoM"
    @steve.email = mixed_case
    @steve.save
    assert_equal mixed_case.downcase, @steve.email
  end

  test "email validation should reject invalid addresses." do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @steve.email = invalid_address
      assert_not @steve.valid?, "#{invalid_address.inspect} should be invalid."
    end
  end

  test "email should be unique." do
    duplicate_user = @steve.dup
    duplicate_user.email = @steve.email.upcase
    @steve.save
    assert_not duplicate_user.valid?
  end

  test "name should not be too long." do
    @steve.name = "a" * 25
    assert_not @steve.valid?
  end

  test "email should not be too long." do
    @steve.email = "a" * 50 + "@example.com"
    assert_not @steve.valid?
  end

  test "password should have a minimum length." do
    @steve.password = @steve.password_confirmation = "a" * 5
    assert_not @steve.valid?
  end

  test "should authenticate on valid password." do
    assert @steve.authenticate("steve12345")
  end

  test "should not authenticate on invalid password." do
    assert_not @steve.authenticate('incorrect')
  end

  test "#initialize_room should create room." do
    @steve.send(:initialize_room)
    assert @steve.room
  end
end
