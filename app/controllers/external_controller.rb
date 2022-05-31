# frozen_string_literal: true

class ExternalController < ApplicationController
  def create
    credentials = request.env['omniauth.auth']
    user_info = credentials['info']

    user = User.find_or_create_by(email: user_info['email']) do |u|
      u.external_id = credentials['uid']
      u.name = user_info['name']
      u.provider = 'greenlight'
    end

    session[:user_id] = user.id

    # TODO: - Ahmad: deal with errors

    redirect_to '/rooms'
  end
end
