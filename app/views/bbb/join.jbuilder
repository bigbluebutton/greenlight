json.messageKey @messageKey
json.message @message
json.status @status
if @response
  json.response do
    json.join_url(@response[:join_url]) if @response[:join_url]
  end
end
