json.partial! 'bbb', messageKey: @messageKey, message: @message, status: @status
unless @response.blank?
  json.response do
    json.join_url(@response[:join_url]) if @response[:join_url]
  end
end
