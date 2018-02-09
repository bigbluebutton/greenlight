module Lti
  class LaunchController < ApplicationController
    layout 'application'

    #skip_authorization_check
    include RailsLti2Provider::ControllerHelpers

    #include AccountsHelper
    include UsersHelper
    include LtiHelper
    include ApplicationHelper


    skip_before_action :verify_authenticity_token

    before_action :log_params
    # find_account executes before set_session_cache
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
      render 'lti/launch/_error', layout: "empty"
    end

    def config_builder
      @platforms = LtiExtensions::LMS.keys
      if params[:platform].nil?
        @placements = LtiExtensions::LMS[:canvas][:placements]
      else
        @placements = LtiExtensions::LMS[params[:platform].to_sym][:placements]
      end
      render 'lti/registration/config_builder'
    end

    def xml_config
      icon_url = request.host_with_port + view_context.image_path('blindside_logo.png')
      tc = IMS::LTI::Services::ToolConfig.new()
      tc.title = "Greenlight"
      #tc.launch_url = lti_launch_url
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
            'name' => "#{session_cache(:first_name)} #{session_cache(:last_name)}"
          }
        })
      end
      # update the email and nickname to match the user since generate_nickname() is used if isProf

      @user.provider = params[:tool_consumer_info_product_family_code]
      session_cache(:nickname, @user.username)
      session_cache(:email, @user.email)

      unless @user.save
        respond_to do |format|
          format.json { render json: @user.errors.full_messages, status: :unprocessable_entity } && return
        end
      end
      # store basic user information for authorization
      session_cache(:launch_user, @user.attributes.slice("id", "uid", "account_id"))

      tool = RailsLti2Provider::Tool.find(session_cache(:tool_id))

      # link the resource id to the tool(keypair) if new
      resource_ids = tool.resource_link_id.split(",")
      unless resource_ids.include?(session_cache(:resource_link_id))
        tool.update(resource_link_id: resource_ids.push(session_cache(:resource_link_id)).join(","))
      end

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
      #update_usages(tool)

      # get the class associated to the resource type in the tool and get the record
      @resource = session_cache(:resourcelink_title).gsub(/\s/,'-')
      session[:user_id] = @user.id

      #redirect_to meeting_room_url(resource: 'rooms', id: @user.encrypted_id)
      if isProf?
        @@path = "#{root_url}rooms/#{@user.encrypted_id}/#{@resource}"
        redirect_to @@path
      else
        if defined? @@path
          redirect_to @@path
        else
          render 'errors/not_created'
        end
      end
    end

    def isProf?
      session_cache(:membership_role).match(/Learner|Student/).nil?
    end

    private
    def update_usages(tool)
      tool_data = tool.usage
      # construct general resource entry if necessary
      unless tool_data['General']
        tool_data['General'] = { 'all_users' => session_cache(:nickname), 'uses' => 1 }
      else
        tool_data['General']['uses'] += 1

        users = tool_data['General']['all_users'].split(",")
        unless users.include? session_cache(:nickname)
          tool_data['General']['all_users'] = (users << session_cache(:nickname)).join(',')
        end
      end

      # construct new user resource entry if necessary
      unless tool_data[session_cache(:resource_link_id)]
        tool_data[session_cache(:resource_link_id)] = { 'users' => {}, 'resource_type' => session_cache(:launch_type) }
      end

      # construct new user data entry if necessary
      unless tool_data[session_cache(:resource_link_id)]['users'][session_cache(:user_id)]
        tool_data[session_cache(:resource_link_id)]['users'][session_cache(:user_id)] = {
          first: session_cache(:first_name),
          last: session_cache(:last_name),
          email: session_cache(:email),
          uses: 1,
          last_login: DateTime.now.to_date.to_s
        }
      else
        tool_data[session_cache(:resource_link_id)]['users'][session_cache(:user_id)]['uses'] += 1
        tool_data[session_cache(:resource_link_id)]['users'][session_cache(:user_id)]['last_login'] = DateTime.now.to_date.to_s
      end

      tool.update_attributes(usage: tool_data, origin: @_respondent_url)
    end

    def set_session_cache
      session_cache(:user_id, params[:user_id])
      session_cache(:lti_version, params[:lti_version])
      set_product_params

      if session_cache(:lti_version) == LTI_10
        # build lti launch session data based on what the lms has supplied
        session_cache(:resourcelink_title, params[:resource_link_title])
        session_cache(:resourcelink_description, params[:resource_link_description])

        # roles are required for lti resources
        raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:insufficient_launch_info) unless params[:roles]
        session_cache(:membership_role, params[:roles])
        set_session_person
      else
        session_cache(:resourcelink_title, params[:custom_resourcelink_title])
        session_cache(:resourcelink_description, params[:custom_resourcelink_description])
        session_cache(:membership_role, params[:custom_membership_role])

        session_cache(:email, params[:custom_person_email_primary])
        session_cache(:first_name, params[:custom_person_name_given])
        session_cache(:last_name, params[:custom_person_name_family])
        session_cache(:nickname, isProf? ? generate_nickname(params[:custom_person_name_full]) : params[:custom_person_name_full])
      end

      tool = RailsLti2Provider::Tool.create!(uuid: ENV['GREENLIGHT_KEY'], shared_secret:ENV['GREENLIGHT_SECRET'], lti_version: 'LTI-1p0', tool_settings:'none', resource_link_id: 'a')
      tool = RailsLti2Provider::Tool.find_by(uuid: request.request_parameters['oauth_consumer_key'])
      tool.resource_link_id = params[:resource_link_id]
      tool.resource_type = 'Room'
      tool.save!
      raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:keypair_not_found) unless tool
      lti_authentication(tool)
      session_cache(:tool_id, @lti_launch.tool_id)
    end

    def set_session_person
      unless (LTI1_RECOMMENDED_PARAMETERS - params.keys).length > 0
        # generate username should a user require to be created
        session_cache(:nickname, isProf? ? generate_nickname(params[:lis_person_name_full]) : params[:lis_person_name_full])
        session_cache(:email,
                      params[:lis_person_contact_email_primary] ? params[:lis_person_contact_email_primary] : "#{session_cache(:nickname)}@nomail")
        session_cache(:first_name, params[:lis_person_name_given])
        session_cache(:last_name, params[:lis_person_name_family])
      else
        generate_names
        set_generated_names
      end
    end

    def generate_names
      # in the case that not all lis person identifiers are supplied
      # set the session data for the parameters that are given
      lis_params = params.select { |k,_| (LTI1_RECOMMENDED_PARAMETERS.include?(k) || k.include?("lis")) && !params[k].blank? }.keys
      lis_params.each do |p|
         if LTI1_PARAMETER_ALIASES[p]
           unless p == "lis_person_name_full" && isProf?
             session_cache(LTI1_PARAMETER_ALIASES[p], params[p])
           else
             session_cache(LTI1_PARAMETER_ALIASES[p], generate_nickname(params[p]))
           end
         end
      end
    end

    def set_generated_names
      # set the parameters that were not given by the lms using fallbacks defined below
      # NO FULL NAME:  use sourcedid                                      (blank if sourcedid unavailable)
      # NO EMAIL:      generate email using resource_link_id and user_id  (raise error if no user_id supplied)
      # NO FIRST NAME: use sourcedid before username                      (unless sourcedid unavailable)
      # NO LAST NAME:  defaults to 'User'

      lis_params = lis_params.join(" ")
      raise RailsLti2Provider::LtiLaunch::Unauthorized.new(:insufficient_launch_info) if !params[:user_id] && !lis_params.include?("email_primary")\

      session_cache(:nickname, isProf? ? generate_nickname(params[:lis_person_sourcedid]) :
                                         params[:lis_person_sourcedid]) if !lis_params.include?("name_full")
      session_cache(:email, "#{Digest::SHA1.hexdigest(session_cache(:resource_link_id)+params[:user_id])}@nomail") if !lis_params.include?("email_primary")
      session_cache(:first_name, !lis_params.include?("person_sourcedid") ? session_cache(:nickname) : params[:lis_person_sourcedid]) if !lis_params.include?("name_given")
      session_cache(:last_name, "User") if !lis_params.include?("name_family")
    end

    def set_referrer_session
      session[:from_launch] = true
      # generate an id for this launch to perform cache lookups
      # since this is the first set_session to be called
      @launch_id = Digest::SHA1.hexdigest(params[:oauth_nonce])

      # edX? (edX does not send a family code) stores the referrer in the first portion of the resource_link_id
      if params[:launch_presentation_return_url].blank? && params[:resource_link_id].match(/^.+?(?=-)/)
        session_cache(:referrer, params[:resource_link_id].match(/^.+?(?=-)/) ? params[:resource_link_id].match(/^.+?(?=-)/)[0] : nil)
      else
        session_cache(:referrer, request.referrer.nil? ? params[:launch_presentation_return_url] : request.referrer)
      end
    end

    # set product specific settings to the cache
    def set_product_params
      session_cache(:resource_link_id, params[:resource_link_id])

      if ["moodle", "Blackboard Learn", "desire2learn", "canvas"].include? params[:tool_consumer_info_product_family_code]
        session_cache(:resource_link_id, Digest::SHA1.hexdigest(params[:tool_consumer_instance_guid] + params[:resource_link_id]))
      end

      if params[:lti_version] == LTI_20
        if params[:tool_consumer_info_product_family_code] == "moodle"
          session_cache(:user_id, params[:custom_user_id])
        end

        if params[:tool_consumer_info_product_family_code] == "canvas"
          session_cache(:resource_link_id, Digest::SHA1.hexdigest(params[:custom_context_id] + params[:resource_link_id]))
        end
      else
        # needs to be a better way to identify if the consumer is edX
        if params[:launch_presentation_return_url].blank? && params[:resource_link_id].match(/^.+?(?=-)/)
          session_cache(:resource_link_id, Digest::SHA1.hexdigest(params[:resource_link_id]))
          # username is stored in sourcedid
          session_cache(:first_name, params[:lis_person_sourcedid])
        end

        if params[:tool_consumer_info_product_family_code] == "sakai"
          session_cache(:resource_link_id, Digest::SHA1.hexdigest(params[:ext_sakai_server] + params[:resource_link_id]))
        end
      end
    end

    def sanitize_resource_type
      if params[:type]
        sanitized_type = params[:type] if AVAILABLE_RESOURCES.keys.include?(params[:type])
      elsif !session_cache(:launch_type).blank?
        type = session_cache(:launch_type)
        sanitized_type = type if AVAILABLE_RESOURCES.keys.include?(type)
      else
        tool = RailsLti2Provider::Tool.find(session_cache(:tool_id))
        # performing a single launch
        sanitized_type = tool.resource_type if AVAILABLE_RESOURCES.keys.include?(tool.resource_type)
      end
      session_cache(:launch_type, sanitized_type)
    end

    # Generates a unique nickname for the user
    # Given fullname="First Middle-Name Last" => firstmnlast[some_random_hex]
    def generate_nickname(fullname)
      name = ""
      unless fullname.blank?
        fullname.downcase.split(/@|_| /).each do |part|
          part.split("-").each do |subpart|
            name += part.length > 5 ? subpart[0] : subpart
          end
        end
      end

      name += SecureRandom.hex(3)
    end

    def initial_launch?(tool)
      # there is no usage data if the launch has not been setup
      return tool.usage[session_cache(:resource_link_id)].nil?
    end

    def log_params
      log_hash params.to_unsafe_h
    end
  end
end
