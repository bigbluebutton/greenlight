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

require_relative 'task_helpers'

namespace :configuration do
  desc 'Checks that the application was configured correctly'
  task check: :environment do
    required_env_vars = %w[SECRET_KEY_BASE BIGBLUEBUTTON_ENDPOINT BIGBLUEBUTTON_SECRET DATABASE_URL REDIS_URL].freeze

    # Initial check that variables are set
    info 'Checking required environment variables:'
    required_env_vars.each do |var|
      failed("#{var} not set correctly") if ENV[var].blank?
    end
    passed

    info 'Checking connection to Postgres Database:'
    begin
      ActiveRecord::Base.connection.verify!
    rescue StandardError => e
      failed("Unable to connect to Database - #{e}")
    end
    passed

    info 'Checking connection to Redis Cache:'
    begin
      Redis.new(url: ENV.fetch('REDIS_URL')).ping
    rescue StandardError => e
      failed("Unable to connect to Redis - #{e}")
    end
    passed

    info 'Checking connection to BigBlueButton:'
    test_request(Rails.configuration.bigbluebutton_endpoint)
    checksum = Digest::SHA1.hexdigest("getMeetings#{Rails.configuration.bigbluebutton_secret}")
    test_request("#{Rails.configuration.bigbluebutton_endpoint}getMeetings?checksum=#{checksum}")
    passed

    if ENV['SMTP_SERVER'].present?
      info 'Checking connection to SMTP Server'
      begin
        UserMailer.with(to: ENV.fetch('SMTP_SENDER_EMAIL', nil), subject: ENV.fetch('SMTP_SENDER_EMAIL', nil)).test_email.deliver_now
      rescue StandardError => e
        failed("Unable to connect to SMTP Server - #{e}")
      end
      passed
    end

    exit 0
  end
end

# Takes the full URL including the protocol
def test_request(url)
  uri = URI(url)
  res = Net::HTTP.get(uri)

  doc = Nokogiri::XML(res)
  failed("Could not get a valid response from BigBlueButton server - #{res}") if doc.css('returncode').text != 'SUCCESS'
rescue StandardError => e
  failed("Error connecting to BigBlueButton server - #{e}")
end

def passed
  success 'Passed'
end

def failed(msg)
  err "Failed - #{msg}"
end
