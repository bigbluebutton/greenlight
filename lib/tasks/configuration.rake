# frozen_string_literal: true

require_relative 'task_helpers'

namespace :configuration do
  desc 'Create an administrator account'
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
      ActiveRecord::Base.establish_connection # Establishes connection
      ActiveRecord::Base.connection # Calls connection object
      failed('Failed to connect to Database') unless ActiveRecord::Base.connected?
    rescue StandardError => e
      failed("Failed to connect to Database - #{e}")
    end
    passed

    info 'Checking connection to Redis Cache:'
    begin
      Redis.new.ping
    rescue StandardError => e
      failed("Failed to connect to Redis - #{e}")
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
        failed("Failed to connect to SMTP Server - #{e}")
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
  exit
end
