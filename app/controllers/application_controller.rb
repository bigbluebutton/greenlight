require 'bigbluebutton_api'
require 'digest/sha1'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  def set_locale
    I18n.locale = http_accept_language.language_region_compatible_from(I18n.available_locales)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user
end
