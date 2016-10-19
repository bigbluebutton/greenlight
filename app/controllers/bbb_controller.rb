class BbbController < ApplicationController

  # GET /join
  # GET /join.json
  def join
    if ( !params.has_key?(:id) )
      render_response("missing_parameter", "meeting token was not included", :bad_request)
    elsif ( !params.has_key?(:name) )
      render_response("missing_parameter", "user name was not included", :bad_request)
    else
      bbb_join_url = helpers.bbb_join_url(params[:id], false, params[:name], false, )
      if bbb_join_url[:returncode]
        logger.info "#Execute the redirect"
        render_response("ok", "execute the redirect", :ok, {:join_url => bbb_join_url[:join_url]})
      else
        render_response("bigbluebutton_error", "join url could not be created", :internal_server_error)
      end
    end
  end

  private
  def render_response(messageKey, message, status, response={})
    respond_to do |format|
      if (status == :ok)
        format.html { render :template => "bbb/join" }
        format.json { render :json => { :messageKey => messageKey, :message => message, :status => status, :response => response }, :status => status }
      else
        format.html { render :template => "errors/error" }
        format.json { render :json => { :messageKey => messageKey, :message => message, :status => status, :response => response }, :status => status }
      end
    end
  end
end
