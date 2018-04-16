module Lti
  class LaunchController < ApplicationController
    layout 'lti'

    skip_authorization_check
    include RailsLti2Provider::ControllerHelpers

    include UsersHelper
    include LtiHelper
    include ApplicationHelper

    skip_before_action :verify_authenticity_token

    before_action :log_params
    before_action :set_referrer_session, :set_session_cache, only: :launch
    after_action :disable_xframe_header

    rescue_from RailsLti2Provider::LtiLaunch::Unauthorized do |ex|
      @error = { key: ex.error,
                 message: 'LTI launch failed: ' + case ex.error
                                                  when :insufficient_launch_info
                                                    I18n.t('lti.errors.insufficient_launch_info')
                                                  when :resources_not_found
                                                    I18n.t('lti.errors.resources_not_found')
                                                  when :resource_not_active
                                                    I18n.t('lti.errors.resource_not_active')
                                                  when :account_not_found
                                                    I18n.t('lti.errors.account_not_found')
                                                  when :requester_url_not_found
                                                    I18n.t('lti.errors.requester_url_not_found')
                                                  when :keypair_not_found
                                                    I18n.t('lti.errors.keypair_not_found')
                                                  when :invalid_signature # bad secret?
                                                    I18n.t('lti.errors.invalid_signature')
                                                  when :invalid_nonce
                                                    I18n.t('lti.errors.invalid_nonce')
                                                  when :request_too_old
                                                    I18n.t('lti.errors.request_too_old')
                                                  else
                                                    I18n.t('lti.errors.unknown')
                                                end }
      disable_xframe_header
      render 'lti/launch/_error', layout: "lti"
    end

    def xml_config
      icon_url = request.host_with_port + view_context.image_path('blindside_logo.png')
      tc = IMS::LTI::Services::ToolConfig.new()
      tc.title = "Greenlight"
      tc.launch_url = lti_launch_url
      #tc.secure_launch_url = lti_launch_url(:protocol => 'https')
      tc.icon = 'http://' + icon_url
      tc.secure_icon = 'https://' + icon_url
      tc.vendor_code = "blindside_networks"
      tc.vendor_name = "Blindside Networks"
      tc.vendor_description = "Blindside Networks is a company dedicated to helping universities, colleges and commercial companies deliver a high-quality learning experience to remote students. We do this by providing commercial support and hosting for BigBlueButton, an open source web conferencing system for distance education."
      tc.vendor_url = "http://www.blindsidenetworks.com/"
      tc.vendor_contact_email = "ffdixon@blindsidenetworks.com"
      tc.vendor_contact_name = "Fred Dixon"
      tc.description = "Embed BigBlueButton virtual rooms within courses to provide on-line office hours, small group collaboration, and on-line lectures."
      tc.cartridge_bundle = "GREENLIGHT_LTI1&2_Bundle"
      tc.cartridge_icon = "GREENLIGHT_LTI1&2_Icon"

      # static canvas placement
      ##tc.set_ext_param('canvas.instructure.com', 'course_navigation', {url: lti_launch_url, text: 'CastleBN'})

      # set user selected placements
      if params[:placements]
        params[:placements].each_pair { |k, v| tc.set_ext_param(LtiExtensions::LMS[params[:platform].to_sym][:platform], k.to_s, {url: lti_launch_url, text: v}) }
      end
      # set custom parameters if any
      if params[:custom]
        params[:custom].each_pair { |k, v| tc.set_custom_param(k.to_s, v) }
      end
      render xml: tc.to_xml(:indent => 2)
    end

    def launch
      #Get the user attempting launch
      @user = User.where(email: session_cache(:email)).first
      if @user
        @user.update(uid: session_cache(:user_id))
      else
        @user = User.from_omniauth({
          'provider' => params[:tool_consumer_info_product_family_code],
          'uid'      => session_cache(:user_id),
          'info'     => {
            'email' => session_cache(:email),
            'nickname' => session_cache(:nickname),
            'name' => "#{session_cache(:first_name)} #{session_cache(:last_name)}",
            'roles' => session_cache(:membership_role)
          }
        })
      end
      # update the email and nickname to match the user since generate_nickname() is used if isProf
      session_cache(:nickname, @user.username)
      session_cache(:email, @user.email)
      unless @user.save
        respond_to do |format|
          format.json { render json: @user.errors.full_messages, status: :unprocessable_entity } && return
        end
      end
      # store basic user information for authorization
      session_cache(:launch_user, @user.attributes.slice("id", "uid"))
      tool = RailsLti2Provider::Tool.find(session_cache(:tool_id))
      @resources = tool.resource_type.split(",")

      self.send(:post_launch)
    end

    def post_launch
      sanitize_resource_type
      # The LTI key does not have an entry in resource_type; did not select any active resource
      raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:resources_not_found) if session_cache(:launch_type).blank?
      tool = RailsLti2Provider::Tool.find(session_cache(:tool_id))
      # Verify that this resource is still active
      raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:resource_not_active) if !tool.resource_type.include?(session_cache(:launch_type))
      # get the class associated to the resource type in the tool and get the record
      session[:user_id] = @user.id
      #redirect_to meeting_room_url
      @resource = session_cache(:resourcelink_title) ? session_cache(:resourcelink_title).gsub(/\s/,'-') : "#{session_cache(:context_title)} Room"
      @room_id = session_cache(:context_title)
      path = "#{root_url}lti/rooms/#{@room_id}/#{@resource}"
      redirect_to path
    end

    def isProf?
      session_cache(:membership_role).match(/Learner|Student/).nil?
    end

    private

    def set_session_cache
      session_cache(:user_id, params[:user_id])
      session_cache(:lti_version, params[:lti_version])
      set_product_params
      if session_cache(:lti_version) == LTI_10
        # build lti launch session data based on what the lms has supplied
        session_cache(:resourcelink_title, params[:resource_link_title])
        session_cache(:resourcelink_description, params[:resource_link_description])
        session_cache(:context_title, params[:context_title])

        # roles are required for lti resources
        raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:insufficient_launch_info) unless params[:roles]
        session_cache(:membership_role, params[:roles])
        set_session_user
        secret = Rails.configuration.greenlight_secret
        tool = RailsLti2Provider::Tool.create!(uuid: Rails.configuration.greenlight_key, shared_secret: secret, lti_version: 'LTI-1p0', tool_settings:'none')
        tool.save!
      else
        session_cache(:resourcelink_id, params[:resource_link_id])
        session_cache(:resourcelink_title, params[:custom_resourcelink_title])
        session_cache(:resourcelink_description, params[:custom_resourcelink_description])
        session_cache(:membership_role, params[:custom_membership_role])
        session_cache(:context_title, params[:custom_context_title])
        session_cache(:email, params[:custom_person_email_primary])
        session_cache(:first_name, params[:custom_person_name_given])
        session_cache(:last_name, params[:custom_person_name_family])
        session_cache(:nickname, isProf? ? generate_nickname(params[:custom_person_name_full]) : params[:custom_person_name_full])
      end
      tool = RailsLti2Provider::Tool.find_by(uuid: request.request_parameters['oauth_consumer_key'])
      tool.shared_secret = secret if session_cache(:lti_version) == LTI_10
      tool.resource_type = 'Room'
      tool.save!
      raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:keypair_not_found) unless tool
      lti_authentication(tool)

      session_cache(:tool_id, @lti_launch.tool_id)
    end

    def set_session_user
      # generate username should a user require to be created
      session_cache(:nickname, isProf? ? generate_nickname(params[:lis_person_name_full]) : params[:lis_person_name_full])
      session_cache(:email, params[:lis_person_contact_email_primary] ? params[:lis_person_contact_email_primary] : "#{session_cache(:nickname)}@nomail")
      session_cache(:first_name, params[:lis_person_name_given])
      session_cache(:last_name, params[:lis_person_name_family])
    end


    def set_referrer_session
      session[:from_launch] = true
      # generate an id for this launch to perform cache lookups
      # since this is the first set_session to be called
      @launch_id = Digest::SHA1.hexdigest(params[:oauth_nonce])

      session_cache(:referrer, request.referrer.nil? ? params[:launch_presentation_return_url] : request.referrer)

    end

    # set product specific settings to the cache
    def set_product_params
      if params[:lti_version] == LTI_20
        #sets paramaters for lti 2.0 launches
        if params[:tool_consumer_info_product_family_code] == "moodle"
          session_cache(:user_id, params[:custom_user_id])
        end
      else
        # needs to be a better way to identify if the consumer is edX
        if params[:launch_presentation_return_url].blank?
          # username is stored in sourcedid
          session_cache(:first_name, params[:lis_person_sourcedid])
        end
      end
    end

    def sanitize_resource_type
      tool = RailsLti2Provider::Tool.find(session_cache(:tool_id))
      # performing a single launch
      sanitized_type = tool.resource_type
      session_cache(:launch_type, sanitized_type)
    end

    def log_params
      log_hash params.to_unsafe_h
    end
  end
end
