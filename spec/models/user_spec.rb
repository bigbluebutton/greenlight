require "rails_helper"

describe User, type: :model do

  it "should be valid." do
    user = create(:user)
    expect(user).to be_valid
  end

  it "name should be present." do
    user = build(:user, name: nil)
    expect(user).to_not be_valid
  end

  it "username should be present." do
    user = build(:user, username: nil)
    expect(user).to_not be_valid
  end

  it "provider should be present." do
    user = build(:user, provider: nil)
    expect(user).to_not be_valid
  end

  it "should allow nil email." do
    user = build(:user, email: nil)
    expect(user).to be_valid
  end

  it "should allow nil uid." do
    user = build(:user, uid: nil)
    expect(user).to be_valid
  end

  it "should allow nil password." do
    user = build(:user, password: nil, password_confirmation: nil)
    expect(user).to be_valid
  end

  it "password should be longer than six characters." do
    user = build(:user, password: "short")
    expect(user).to_not be_valid
  end

  it "should create user from omniauth." do
    auth = {
      "uid" => "123456789",
      "provider" => "twitter",
      "info" => {
        "name" => "Test Name",
        "nickname" => "username",
        "email" => "test@example.com"
      }
    }

    user = User.from_omniauth(auth)

    expect(user.name).to eql(auth["info"]["name"])
    expect(user.username).to eql(auth["info"]["nickname"])
  end

  it "email addresses should be saved as lower-case." do
    mixed = "ExAmPlE@eXaMpLe.CoM"

    user = build(:user, email: mixed)
    user.save

    expect(user.email).to eql(mixed.downcase)
  end

  it "email validation should reject invalid addresses." do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    user = create(:user)

    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).to_not be_valid
    end
  end

  it "email should be unique." do
    user = create(:user)
    duplicate = user.dup

    expect(duplicate).to_not be_valid
  end

  it "name should not be too long." do
    user = build(:user, name: "a" * 25)
    expect(user).to_not be_valid
  end

  it "email should not be too long." do
    user = build(:user, email: "a" * 50 + "@example.com")
    expect(user).to_not be_valid
  end

  it "should generate room and meeting when saved." do
    user = create(:user)
    user.save

    expect(user.room).to be_instance_of Room
    expect(user.room.meeting).to be_instance_of Meeting
  end
end