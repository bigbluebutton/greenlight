module LandingHelper
  def new_meeting_token
    rand.to_s[2..10]
  end
end
