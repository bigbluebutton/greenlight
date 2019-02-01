# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    url = "http://example.com" + "/password_resets/" + user.reset_token + "/edit?email=" + user.email
    UserMailer.password_reset(user, url)
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/verify_email
  def verify_email
    user = User.first
    url = "http://example.com" + "/u/verify/confirm/" + user.uid
    UserMailer.verify_email(user, url)
  end
end
