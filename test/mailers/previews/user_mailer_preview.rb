# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def test_email
    UserMailer.with(to: 'user@users.com', subject: 'Test Subject').test_email
  end

  def reset_password_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users.com'), expires_in: 1.hour.from_now, reset_url: 'https://example.com/reset').reset_password_email
  end

  def activate_account_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users.com'), expires_in: 1.hour.from_now, activation_url: 'https://example.com/activate').activate_account_email
  end

  def invitation_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users'), expires_in: 1.hour.from_now, invitation_url: 'https://example.com/invite').invitation_email
  end
end
