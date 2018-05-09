require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(
      name: "Example User",
      username: "Username",
      provider: "greenlight",
      email: "user@example.com",
      password: "example",
      password_confirmation: "example"
    )
  end

  test "should be valid." do
    assert @user.valid?
  end

  test "name should be present." do
    @user.name = nil
    assert_not @user.valid?
  end

  test "email should be present." do
    @user.email = nil
    assert_not @user.valid?
  end

  test "username should be present." do
    @user.username = nil
    assert_not @user.valid?
  end

  test "provider should be present." do
    @user.provider = nil
    assert_not @user.valid?
  end

  test "should allow nil uid." do
    @user.uid = nil
    assert @user.valid?
  end

  test "should allow nil password." do
    @user.password = @user.password_confirmation = nil
    assert @user.valid?
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
    @user.email = mixed_case
    @user.save
    assert_equal mixed_case.downcase, @user.email
  end

  test "email validation should reject invalid addresses." do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid."
    end
  end

  test "email should be unique." do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "name should not be too long." do
    @user.name = "a" * 25
    assert_not @user.valid?
  end

  test "email should not be too long." do
    @user.email = "a" * 50 + "@example.com"
    assert_not @user.valid?
  end

  test "password should have a minimum length." do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "should authenticate on valid password." do
    assert_not_equal @user.authenticate('example'), false
  end

  test "should not authenticate on invalid password." do
    assert_not @user.authenticate('incorrect')
  end

  test "should create room when saved." do
    @user.save
    assert @user.room
  end
end
