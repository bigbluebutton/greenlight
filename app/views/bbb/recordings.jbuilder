json.partial! 'bbb', messageKey: @messageKey, message: @message, status: @status
unless @response.blank?
  json.is_owner current_user == @user
  json.recordings do
    unless @response.is_a? Array
      @response = [@response]
    end
    json.array!(@response) do |recording|
      json.id recording[:recordID]
      json.name recording[:name]
      json.start_time recording[:startTime]
      json.end_time recording[:endTime]
      json.published recording[:published]
      json.playbacks do
        unless recording[:playback][:format].is_a? Array
          recording[:playback][:format] = [recording[:playback][:format]]
        end
        json.array!(recording[:playback][:format]) do |playback|
          json.type playback[:type]
          json.url playback[:url]
        end
      end
    end
  end
end
