# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def recording_ready_email_preview
    NotificationMailer.recording_ready_email(User.first)
  end
end
