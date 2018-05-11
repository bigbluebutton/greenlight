module SessionsHelper
  # Logs a user into GreenLight.
  def login(user)
    session[:user_id] = user.id
    redirect_to room_path(user.room.uid)
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
