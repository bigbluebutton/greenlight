# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # TODO: add i18n.
  # rubocop:disable Rails/I18nLocaleTexts
  # Sends a test email
  def test_email
    mail(to: params[:to], subject: params[:subject])
  end

  def reset_password_email
    @user = params[:user]
    @reset_url = params[:reset_url]
    @expires_in = params[:expires_in]

    mail(to: email_address_with_name(@user.email, @user.name), subject: 'Reset Password')
  end

  def activate_account_email
    @user = params[:user]
    @activation_url = params[:activation_url]
    @expires_in = params[:expires_in]

    mail(to: email_address_with_name(@user.email, @user.name), subject: 'Account Activation')
  end
  # rubocop:enable Rails/I18nLocaleTexts
end
