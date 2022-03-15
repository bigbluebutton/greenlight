
require 'bigbluebutton_api'

class BigBlueButtonApi

  # Sets a BigBlueButtonApi object for interacting with the API.
  def initialize
  end

  # Insert functions that call the api functions here...
  def get_meetings
    #binding.break
    bbb_server.get_meetings
  end



  private
    def bbb_server
      # TODO: Add additional logic here...
      @bbb_server ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint, bbb_secret, "0.8", true)
    end

    def bbb_endpoint
      ENV['BIGBLUEBUTTON_ENDPOINT']
    end

    def bbb_secret
      ENV['BIGBLUEBUTTON_SECRET']
    end
end
