module RecordingChecker
  extend BbbServer
  extend Recorder

  RECORDINGS_ENDPOINT = "#{ENV['BIGBLUEBUTTON_ENDPOINT']}record/"

  def recording_link(record_id, format: :mp4)
    "#{RECORDINGS_ENDPOINT.remove('/bigbluebutton')}#{record_id}.#{format}"
  end

  module_function :recording_link

  def call
    User.find_each do |user|
      all_recordings(user.rooms.pluck(:bbb_id)).each do |recording|
        RecordingStatus.find_or_create_by(record_id: recording[:recordID])
      end
    end
  end

  module_function :call

  def available?(record_id, format: :mp4)
    uri = URI(ENV['BIGBLUEBUTTON_ENDPOINT'])
    path = "/record/#{record_id}.#{format}"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    response = http.head(path)
    response.code == '200'
  end

  module_function :available?

  def bbb_server
    Rails.configuration.loadbalanced_configuration ? bbb(@user_domain) : bbb("greenlight")
  end

  module_function :bbb_server
end
