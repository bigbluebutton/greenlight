json.partial! 'bbb', messageKey: @messageKey, message: @message, status: @status
unless @response.blank?
  json.is_owner current_user == @user
  json.recordings do
    json.array!(@response) do |recording|
      json.id recording[:recordID]
      json.name recording[:name]
      json.start_time recording[:startTime]
      json.end_time recording[:endTime]
      json.published recording[:published]
      json.previews do
        json.array!(recording[:previews]) do |preview|
          json.partial! 'preview', preview: preview
        end
      end
      json.playbacks do
        json.array!(recording[:playbacks]) do |playback|
          json.type t(playback[:type]) # translates the playback type
          json.url playback[:url]
          json.previews do
            json.array!(playback[:previews]) do |preview|
              json.partial! 'preview', preview: preview
            end
          end
        end
      end
    end
  end
end
