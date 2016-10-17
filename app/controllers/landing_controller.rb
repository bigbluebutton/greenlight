class LandingController < ApplicationController
  def index
    @meeting_token = params[:id] || @meeting_token = rand.to_s[2..10]
    @meeting_url = meeting_url(@meeting_token)
  end
  
  private
  def meeting_url(meeting_token)
    _meeting_url = "#{request.original_url}"
    _meeting_url += "meeting" if ( request.original_url == "#{request.base_url}/" )
    _meeting_url += "/" unless _meeting_url.end_with?('/')
    _meeting_url += "#{meeting_token}" if !params.has_key?(:id)
    _meeting_url
  end
end
