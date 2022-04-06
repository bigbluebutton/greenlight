# frozen_string_literal: true

require 'bigbluebutton_api'

class BigBlueButtonApi
  def initialize; end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb_server
    # TODO: Amir - Protect the BBB secret.
    # TODO: Hadi - Add additional logic here...
    @bbb_server ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint, bbb_secret, '1.8')
  end

  private

  def bbb_endpoint
    ENV.fetch 'BIGBLUEBUTTON_ENDPOINT', 'https://test-install.blindsidenetworks.com/bigbluebutton/api'
  end

  def bbb_secret
    ENV.fetch 'BIGBLUEBUTTON_SECRET', '8cd8ef52e8e101574e400365b55e11a6'
  end
end
