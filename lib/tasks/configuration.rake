require 'net/http'
require 'nokogiri'
require 'digest/sha1'

namespace :conf  do
  desc "Check Configuration"
  task :check => :environment do
    ENV_VARIABLES = ['SECRET_KEY_BASE', 'BIGBLUEBUTTON_ENDPOINT', 'BIGBLUEBUTTON_SECRET']

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
  end

  desc "Check Email Configuration"
  task :check_email, [:email] => :environment do |task, args|
    ENV_VARIABLES = ['GREENLIGHT_MAIL_NOTIFICATIONS', 'GREENLIGHT_DOMAIN',
      'SMTP_FROM', 'SMTP_SERVER', 'SMTP_PORT', 'SMTP_DOMAIN',
      'SMTP_USERNAME', 'SMTP_PASSWORD']
    email_address = args[:email]

    print "Checking environment"
    ENV_VARIABLES.each do |var|
      if ENV[var].blank?
        failed("#{var} not set correctly")
      end
    end
    passed

    # send a test email to specified email address
    print "Sending Test Email:"
    if email_address
      print "\n"
      send_email(email_address)
    else
      failed("No email address specified")
    end
  end
end

# takes the full URL including the protocol
def test_request(url)
  begin
    uri = URI(url)
    res = Net::HTTP.get(uri)

    doc = Nokogiri::XML(res)
    if doc.css("returncode").text != "SUCCESS"
      failed("Could not get a valid response from BigBlueButton server - #{res}")
    end
  rescue => exc
    failed("Error connecting to BigBlueButton server - #{exc}")
  end
end

def send_email(email_address)
  TestMailer.test_email(email_address).deliver
rescue => exc
  print("Error sending test email - #{exc}\n")
  exit
end

def failed(msg)
  print(": Failed\n#{msg}\n")
  exit
end

def passed()
  print(": Passed\n")
end
