class LandingController < ApplicationController
  include LandingHelper

  def index
    @meeting_token = params[:id] || @meeting_token = rand.to_s[2..10]
    @meeting_url = meeting_url(@meeting_token)
  end
end
