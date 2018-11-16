# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'digest/sha1'

namespace :conf do
  desc "Check Configuration"
  task check: :environment do
    ENV_VARIABLES = %w(SECRET_KEY_BASE BIGBLUEBUTTON_ENDPOINT BIGBLUEBUTTON_SECRET)

    # Initial check that variables are set
    print "\nChecking environment"
    ENV_VARIABLES.each do |var|
      if ENV[var].blank?
        failed("#{var} not set correctly")
      end
    end
    passed

    # Tries to establish a connection to the BBB server from Greenlight
    print "Checking Connection"
    test_request(ENV['BIGBLUEBUTTON_ENDPOINT'])
    passed

    # Tests the checksum on the getMeetings api call
    print "Checking Secret"
    checksum = Digest::SHA1.hexdigest("getMeetings#{ENV['BIGBLUEBUTTON_SECRET']}")
    test_request("#{ENV['BIGBLUEBUTTON_ENDPOINT']}api/getMeetings?checksum=#{checksum}")
    passed

    # Tests the checksum on the getMeetings api call
    print "Checking SMTP connection"
    test_smtp
    passed
  end
end

def test_smtp
  smtp = Net::SMTP.new(ENV['SMTP_SERVER'], ENV['SMTP_PORT'])
  if ENV['SMTP_STARTTLS_AUTO']
    smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)
  end

  smtp.start(ENV['SMTP_DOMAIN'], ENV['SMTP_USERNAME'], ENV['SMTP_PASSWORD'],
    ENV['SMTP_AUTH']) do |s|
    s.sendmail('test', ENV['SMTP_USERNAME'], 'notifications@example.com')
  end
rescue => exc
  failed("Error connecting to SMTP - #{exc}")
end

# takes the full URL including the protocol
def test_request(url)
  uri = URI(url)
  res = Net::HTTP.get(uri)

  doc = Nokogiri::XML(res)
  if doc.css("returncode").text != "SUCCESS"
    failed("Could not get a valid response from BigBlueButton server - #{res}")
  end
rescue => exc
  failed("Error connecting to BigBlueButton server - #{exc}")
end

def failed(msg)
  print(": Failed\n#{msg}\n")
  exit
end

def passed
  print(": Passed\n")
end
