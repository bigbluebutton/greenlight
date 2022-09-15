# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # Sends a test email
  def test_email
    mail(to: params[:to], subject: params[:subject])
  end
end
