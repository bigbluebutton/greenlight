#!/usr/bin/ruby

##################################################################
# Make sure the dependencies of gems are met
#
# gem install jwt
# gem install java_properties
##################################################################

#
# Example of a post publish script to send an event to GreenLight
# whenever a recording is published in the BigBlueButton server.
#
# Uses the same data format and checksum calculation method used by
# the webhooks module.
#

require "trollop"
require "net/http"
require "jwt"
require "java_properties"
require "json"
require "digest/sha1"
require "uri"
require File.expand_path('../../../lib/recordandplayback', __FILE__)

# Get the list of participants
def getParticipantsInfo(events_xml)
  BigBlueButton.logger.info("Task: Getting participants info")
  doc = Nokogiri::XML(File.open(events_xml))
  participants_ids = []
  participants_info = []

  doc.xpath("//event[@eventname='ParticipantJoinEvent']").each do |joinEvent|
     userId = joinEvent.xpath(".//userId").text

     #removing "_N" at the end of userId
     userId.gsub!(/_\d*/, "")

     if !participants_ids.include? userId
        participants_ids << userId

        participant_name = joinEvent.xpath(".//name").text
        participant_role = joinEvent.xpath(".//role").text
        participants_info << [userId, participant_name, participant_role]
     end
  end
  participants_info
end

# Gets the join and leave times for each user, as well as total duration of stay.
def get_duration_info(events_xml)
  BigBlueButton.logger.info("Task: Getting duration information.")
  doc = Nokogiri::XML(File.open(events_xml))
  user_data = {}
  first_event_time = BigBlueButton::Events.first_event_timestamp(events_xml)
  timestamp = doc.at_xpath('/recording')['meeting_id'].split('-')[1].to_i
  joinEvents = doc.xpath('/recording/event[@module="PARTICIPANT" and @eventname="ParticipantJoinEvent"]')
  leftEvents = doc.xpath('/recording/event[@module="PARTICIPANT" and @eventname="ParticipantLeftEvent"]')
  # This should never occur, but just in case.
  return {'error' => 'inequal number of join/left events.'} if joinEvents.length != leftEvents.length
  joinEvents.each do |join|
    uID = join.xpath('externalUserId').text
    user_data[uID] = {}
    user_data[uID]['name'] = join.xpath('name').text
    user_data[uID]['join'] = join['timestamp'].to_i - first_event_time + timestamp
    user_data[uID]['role'] = join.xpath('role').text
  end
  leftEvents.each do |left|
    uID = left.xpath('userId').text.split('_')[0]
    user_data[uID]['left'] = left['timestamp'].to_i - first_event_time + timestamp
    user_data[uID]['duration'] = user_data[uID]['left'] - user_data[uID]['join']
  end
  user_data
end

logger = Logger.new("/var/log/bigbluebutton/post_process.log", 'weekly')
logger.level = Logger::INFO
BigBlueButton.logger = logger

opts = Trollop::options do
  opt :meeting_id, "Meeting id to archive", :type => String
end
meeting_id = opts[:meeting_id]

events_xml = "/var/bigbluebutton/recording/raw/#{meeting_id}/events.xml"
meeting_metadata = BigBlueButton::Events.get_meeting_metadata(events_xml)

BigBlueButton.logger.info("Post Process: Recording Notify for [#{meeting_id}] starts")

begin
  callback_url = meeting_metadata["gl-webhooks-callback-url"]

  unless callback_url.nil?
    BigBlueButton.logger.info("Making callback for recording ready notification")

    participants_info = getParticipantsInfo(events_xml)
    duration_info = get_duration_info(events_xml)

    props = JavaProperties::Properties.new("/var/lib/tomcat7/webapps/bigbluebutton/WEB-INF/classes/bigbluebutton.properties")
    secret = props[:securitySalt]

    timestamp = Time.now.to_i
    event = {
      "header": {
        "name": "publish_ended"
      },
      "payload":{
        "metadata": meeting_metadata,
        "meeting_id": meeting_id,
        "participants": participants_info,
        "duration": duration_info
      }
    }
    payload = {
      event: event,
      timestamp: timestamp
    }

    checksum_str = "#{callback_url}#{payload.to_json}#{secret}"
    checksum = Digest::SHA1.hexdigest(checksum_str)
    BigBlueButton.logger.info("Got checksum #{checksum} for #{checksum_str}")

    separator = URI.parse(callback_url).query ? "&" : "?"
    uri = URI.parse("#{callback_url}#{separator}checksum=#{checksum}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = payload.to_json
    BigBlueButton.logger.info("Posted event to #{callback_url}")

    response = http.request(request)
    code = response.code.to_i

    if code == 410
      BigBlueButton.logger.info("Notified for deleted meeting: #{meeting_id}")
      # TODO: should we automatically delete the recording here?
    elsif code == 404
      BigBlueButton.logger.warn("404 error when notifying for recording: #{meeting_id}, ignoring")
    elsif code < 200 || code >= 300
      BigBlueButton.logger.debug("Callback HTTP request failed: #{response.code} #{response.message} (code #{code})")
    else
      BigBlueButton.logger.debug("Recording notifier successful: #{meeting_id} (code #{code})")
    end

  else
    BigBlueButton.logger.info("Blank callback URL, aborting.")
  end

rescue => e
  BigBlueButton.logger.info("Rescued")
  BigBlueButton.logger.info(e.to_s)
end

BigBlueButton.logger.info("Post Process: Recording Notify ends")

exit 0
