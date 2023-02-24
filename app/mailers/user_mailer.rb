# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :preset, :branding # :preset must be called before :branding.

  # Sends a test email
  def test_email
    mail(to: params[:to], subject: params[:subject])
  end

  def reset_password_email
    @user = params[:user]
    @reset_url = params[:reset_url]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.reset.password_reset'))
  end

  def activate_account_email
    @user = params[:user]
    @activation_url = params[:activation_url]

    mail(to: email_address_with_name(@user.email, @user.name), subject: t('email.activation.account_activation'))
  end

  def invitation_email
    @email = params[:email]
    @name = params[:name]
    @signup_url = params[:signup_url]
    @email = params[:email]

    mail(to: @email, subject: t('email.invitation.invitation_to_join'))
  end

  private

  def preset
    @provider = params[:provider] || 'greenlight'
    @base_url = params[:base_url]
  end

  def branding
    branding_hash = SiteSetting.includes(:setting).where(provider: @provider, settings: { name: %w[PrimaryColor BrandingImage] })
                               .pluck(:name, :value).to_h
    @brand_image = ActionController::Base.helpers.image_url(branding_hash['BrandingImage'], host: @base_url)
    @brand_color = branding_hash['PrimaryColor']
  end
end
