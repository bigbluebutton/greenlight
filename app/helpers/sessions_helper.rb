module SessionsHelper
  
  # Logs a user into GreenLight.
  def login(user)
    session[:user_id] = user.id

    # If there are not terms, or the user has accepted them, go to their room.
    if !Rails.configuration.terms || user.accepted_terms then
      redirect_to user.main_room
    else
      redirect_to terms_path
    end
  end

  # Logs current user out of GreenLight.
  def logout
    session.delete(:user_id) if current_user
  end

  # Retrieves the current user.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
