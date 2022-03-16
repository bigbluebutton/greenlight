# frozen_string_literal: true

require 'bigbluebutton_api'

class BigBlueButtonApi
  def initialize; end

  private

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb_server
    # TODO: Add additional logic here...
    @bbb_server ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint, bbb_secret, '1.0')
  end

  def bbb_endpoint
    ENV['BIGBLUEBUTTON_ENDPOINT']
  end

  def bbb_secret
    ENV['BIGBLUEBUTTON_SECRET']
  end
end
