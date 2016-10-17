require 'bigbluebutton_api'
require 'digest/sha1'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
end
