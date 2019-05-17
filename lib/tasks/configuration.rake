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
      failed("#{var} not set correctly") if ENV[var].blank?
    end
    passed

    # Tries to establish a connection to the BBB server from Greenlight
    print "Checking Connection"
    test_request(ENV['BIGBLUEBUTTON_ENDPOINT'])
    passed

    # Tests the checksum on the getMeetings api call
    print "Checking Secret"
    checksum = Digest::SHA1.hexdigest("getMeetings#{ENV['BIGBLUEBUTTON_SECRET']}")
    test_request("#{ENV['BIGBLUEBUTTON_ENDPOINT']}getMeetings?checksum=#{checksum}")
    passed

    if ENV['ALLOW_MAIL_NOTIFICATIONS'] == 'true'
      # Tests the configuration of the SMTP Server
      print "Checking SMTP connection"
      test_smtp
      passed
    end
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
rescue => e
  failed("Error connecting to SMTP - #{e}")
end

# Takes the full URL including the protocol
def test_request(url)
  uri = URI(url)
  res = Net::HTTP.get(uri)

  doc = Nokogiri::XML(res)
  failed("Could not get a valid response from BigBlueButton server - #{res}") if doc.css("returncode").text != "SUCCESS"
rescue => e
  failed("Error connecting to BigBlueButton server - #{e}")
end

def failed(msg)
  print(": Failed\n#{msg}\n")
  exit
end

def passed
  print(": Passed\n")
end
