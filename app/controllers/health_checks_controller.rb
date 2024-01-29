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

class HealthChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def check
    response = 'success'

    begin
      check_database unless ENV.fetch('DATABASE_HEALTH_CHECK_DISABLED', false) == 'true'
      check_redis unless ENV.fetch('REDIS_HEALTH_CHECK_DISABLED', false) == 'true'
      check_smtp unless ENV.fetch('SMTP_HEALTH_CHECK_DISABLED', false) == 'true'
      check_big_blue_button unless ENV.fetch('BBB_HEALTH_CHECK_DISABLED', false) == 'true'
    end

    render plain: response, status: :ok
  rescue StandardError => e
    logger.error "Health check failed: #{e}"
    render plain: e, status: :internal_server_error
  end

  private

  def check_database
    raise 'Unable to connect to Database' unless ActiveRecord::Base.connection.active?
    raise 'Unable to connect to Database - pending migrations' unless ActiveRecord::Migration.check_all_pending!.nil?
  rescue StandardError => e
    raise "Unable to connect to Database - #{e}"
  end

  def check_redis
    Redis.new.ping
  rescue StandardError => e
    raise "Unable to connect to Redis - #{e}"
  end

  def check_smtp
    settings = ActionMailer::Base.smtp_settings

    smtp = Net::SMTP.new(settings[:address], settings[:port])
    smtp.enable_starttls_auto if settings[:openssl_verify_mode] != OpenSSL::SSL::VERIFY_NONE && smtp.respond_to?(:enable_starttls_auto)

    if settings[:authentication].present? && settings[:authentication] != 'none'
      smtp.start(settings[:domain]) do |s|
        s.authenticate(settings[:user_name], settings[:password], settings[:authentication])
      end
    else
      smtp.start(settings[:domain])
    end
    smtp.finish
  rescue StandardError => e
    raise "Unable to connect to SMTP Server - #{e}"
  end

  def check_big_blue_button
    checksum = Digest::SHA1.hexdigest("isMeetingRunningmeetingID=0#{Rails.configuration.bigbluebutton_secret}")
    uri = URI("#{Rails.configuration.bigbluebutton_endpoint}isMeetingRunning?meetingID=0&checksum=#{checksum}")
    res = Net::HTTP.get(uri)
    doc = Nokogiri::XML(res)

    raise "Unable to connect to BigBlueButton - #{res}" unless doc.css('returncode').text == 'SUCCESS'
  rescue StandardError => e
    raise "Unable to connect to BigBlueButton - #{e}"
  end
end
