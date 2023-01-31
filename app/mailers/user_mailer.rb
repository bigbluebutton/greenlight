# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :branding

  # Sends a test email
  def test_email
    mail(to: params[:to], subject: params[:subject])
  end

  def reset_password_email
    @user = params[:user]
    @reset_url = params[:reset_url]
    @expires_in = params[:expires_in]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.reset.password_reset'))
  end

  def activate_account_email
    @user = params[:user]
    @activation_url = params[:activation_url]
    @expires_in = params[:expires_in]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.activation.account_activation'))
  end

  def invitation_email
    @name = params[:name]
    @signup_url = params[:signup_url]
    @email = params[:email]

    mail(to: @email, subject: t('email.invitation.invitation_to_join'))
  end

  def branding
    branding_hash = SiteSetting.includes(:setting).where(settings: { name: %w[PrimaryColor BrandingImage] }).pluck(:'settings.name', :value).to_h
    @brand_image = branding_hash['BrandingImage']
    @brand_color = branding_hash['PrimaryColor']
  end
end
