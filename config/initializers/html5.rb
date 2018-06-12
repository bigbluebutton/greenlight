# Send a request to check if the HTML5 client is enabled on the BigBlueButton server.
uri = URI.parse(Rails.configuration.bigbluebutton_endpoint.gsub('bigbluebutton/api', 'html5client/check'))
res = Net::HTTP.get_response(uri)

# Set the HTML5 status.
Rails.application.config.html5_enabled = (res.code.to_i == 200)
