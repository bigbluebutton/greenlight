# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def test_email
    UserMailer.with(to: 'user@users.com', subject: 'Test Subject').test_email
  end
end
