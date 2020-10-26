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

    endpoint = fix_endpoint_format(ENV['BIGBLUEBUTTON_ENDPOINT'])

    # Tries to establish a connection to the BBB server from Greenlight
    print "Checking Connection"
    test_request(endpoint)
    passed

    # Tests the checksum on the getMeetings api call
    print "Checking Secret"
    checksum = Digest::SHA1.hexdigest("getMeetings#{ENV['BIGBLUEBUTTON_SECRET']}")
    test_request("#{endpoint}getMeetings?checksum=#{checksum}")
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
  TestMailer.test_email(ENV.fetch('SMTP_SENDER', 'notifications@example.com'),
                        ENV.fetch('SMTP_TEST_RECIPIENT', 'notifications@example.com')).deliver
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

def fix_endpoint_format(url)
  # Fix endpoint format if required.
  url += "/" unless url.ends_with?('/')
  url += "api/" if url.ends_with?('bigbluebutton/')
  url += "bigbluebutton/api/" unless url.ends_with?('bigbluebutton/api/')

  url
end

def failed(msg)
  print(": Failed\n#{msg}\n")
  exit
end

def passed
  print(": Passed\n")
end

class TestMailer < ActionMailer::Base
  def test_email(sender, recipient)
    mail(to: recipient,
      from: sender,
      subject: "Greenlight Email Test",
      body: "This is what people with plain text mail readers will see.",
      content_type: "text/plain",)
  end
end
