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

def failed(msg)
  print(": Failed\n#{msg}\n")
  exit
end

def passed()
  print(": Passed\n")
end
