# frozen_string_literal: true

require 'bigbluebutton_api'

def bbb_endpoint
  Rails.configuration.bigbluebutton_endpoint
end

def bbb_secret
  Rails.configuration.bigbluebutton_secret
end

def remove_slash(s)
  s.nil? ? nil : s.chomp("/")
end

def test_bbb_connection
  unless Rails.configuration.loadbalanced_configuration
    BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8").test_connection
  end
  true
rescue BigBlueButton::BigBlueButtonException => exc
  puts "ERROR: " + exc.to_s
  false
end

Rails.configuration.bbb_connect = test_bbb_connection
