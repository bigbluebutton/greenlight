# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def initialize
    @logo = "https://raw.githubusercontent.com/bigbluebutton/greenlight/master/app/assets/images/logo_with_text.png"
    @color = "#467fcf"
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    url = "http://example.com" + "/password_resets/" + user.reset_token + "/edit?email=" + user.email
    UserMailer.password_reset(user, url, @logo, @color)
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/verify_email
  def verify_email
    user = User.first
    url = "http://example.com" + "/u/verify/confirm/" + user.uid
    UserMailer.verify_email(user, url, @logo, @color)
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/invite_email
  def invite_email
    UserMailer.invite_email("Example User", "from@example.com", "http://example.com/signup", @logo, @color)
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/approve_user
  def approve_user
    user = User.first
    UserMailer.approve_user(user, "http://example.com/", @logo, @color)
  end
end
