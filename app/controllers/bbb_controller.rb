class BbbController < ApplicationController

  # GET /:resource/:id/join
  def join
    if ( !params[:id] )
      render_response("missing_parameter", "meeting token was not included", :bad_request)
    elsif ( !params[:name] )
      render_response("missing_parameter", "user name was not included", :bad_request)
    else
      user = User.find_by username: params[:id]

      options = if user
        {
          wait_for_moderator: true,
          user_is_moderator: current_user == user
        }
      else
        {}
      end
      options[:meeting_logout_url] = "#{request.base_url}/#{params[:resource]}/#{params[:id]}"

      bbb_res = helpers.bbb_join_url(
        params[:id],
        params[:name],
        options
      )

      render_response bbb_res[:messageKey], bbb_res[:message], bbb_res[:status], bbb_res[:response]
    end
  end

  private
  def render_response(messageKey, message, status, response={})
    @messageKey = messageKey
    @message = message
    @status = status
    @response = response
    render status: @status && return
  end
end
