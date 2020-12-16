# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class HealthCheckController < ApplicationController
  skip_before_action :redirect_to_https, :set_user_domain, :set_user_settings, :maintenance_mode?, :migration_error?,
  :user_locale, :check_admin_password, :check_user_role

  # GET /health_check
  def all
    response = "success"
    @cache_expire = 10.seconds

    begin
      cache_check
      database_check
      email_check
    rescue => e
      response = "Health Check Failure: #{e}"
    end

    render plain: response
  end

  private

  def cache_check
    if Rails.cache.write("__health_check_cache_write__", "true", expires_in: @cache_expire)
      raise "Unable to read from cache" unless Rails.cache.read("__health_check_cache_write__") == "true"
    else
      raise "Unable to write to cache"
    end
  end

  def database_check
    if defined?(ActiveRecord)
      raise "Database not responding" unless ActiveRecord::Migrator.current_version
    end
    raise "Pending migrations" unless ActiveRecord::Migration.check_pending!.nil?
  end

  def email_check
    test_smtp if Rails.configuration.action_mailer.delivery_method == :smtp
  end

  def test_smtp
    settings = ActionMailer::Base.smtp_settings

    smtp = Net::SMTP.new(settings[:address], settings[:port])
    if settings[:enable_starttls_auto] == "true"
      smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)
    end

    if settings[:authentication].present? && settings[:authentication] != "none"
      smtp.start(settings[:domain]) do |s|
        s.authenticate(settings[:user_name], settings[:password], settings[:authentication])
      end
    else
      smtp.start(settings[:domain])
    end
  rescue => e
    raise "Unable to connect to SMTP Server - #{e}"
  end
end
