module Lti
  class ToolProxyController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      registration_request = IMS::LTI::Models::Messages::RegistrationRequest.new(params)
      registration_service = IMS::LTI::Services::ToolProxyRegistrationService.new(registration_request)
      @tool_consumer_profile = registration_service.tool_consumer_profile

      tool_service = registration_service.service_profiles
      #filter out unwanted services
      security_contract = IMS::LTI::Models::SecurityContract.new(
        shared_secret: 'secret',
      # tool_service: tool_service,
      # end_user_service: [IMS::LTI::Models::RestServiceProfile.new]
      )

      tool_proxy = IMS::LTI::Models::ToolProxy.new(
        id: "instructure.com/tool-provider-example:#{SecureRandom.uuid}",
        lti_version: 'LTI-2p0',
        security_contract: security_contract,
        tool_consumer_profile: registration_request.tc_profile_url,
        tool_profile: tool_profile,
      )

      if registration_service.register_tool_proxy(tool_proxy)
        redirect_to registration_request.launch_presentation_return_url
      else
        render text: "Failed to create a tool proxy in #{@tool_consumer_profile.product_instance.product_info.product_name.default_value}"
      end
    end

    private
    def product_instance
      product_instance = IMS::LTI::Models::ProductInstance.new.from_json(File.read(File.join(Rails.root, 'config', 'product_instance.json')))

      product_instance.guid = LTI_CONFIG[:product_instance_guid] || 'invalid'
      product_instance.product_info.product_version = '2.x'
      product_instance
    end

    def tool_profile
      message = IMS::LTI::Models::MessageHandler.new(
        message_type: 'basic-lti-launch-request',
        path: messages_blti_url,
        parameter: variable_parameters + fixed_parameters
      )

      resource_handler = IMS::LTI::Models::ResourceHandler.from_json(
        {
          resource_type: {code: 'placements'},
          resource_name: {default_value: 'lti_example_tool', key: ''},
          message: message.as_json
        }
      )
      resource_handler.ext_placements = placements if placements.present?


      IMS::LTI::Models::ToolProfile.new(
        lti_version: 'LTI-2p0',
        product_instance: product_instance,
        resource_handler: [resource_handler]
      )
    end

    def variable_parameters
      parameters = @tool_consumer_profile.capability_offered - (IMS::LTI::Models::ToolConsumerProfile::MESSAGING_CAPABILITIES + IMS::LTI::Models::ToolConsumerProfile::OUTCOMES_CAPABILITIES + ['Canvas.placements.course-nav', 'Canvas.placements.account-nav'] )
      parameters.map { |p| IMS::LTI::Models::Parameter.new(name: p.downcase.gsub('.', '_'), variable: p) }
    end

    def fixed_parameters
      [
        IMS::LTI::Models::Parameter.new(name: 'fixed_value_param', fixed: 42)
      ]
    end

    def placements
      @tool_consumer_profile.capability_offered & ['Canvas.placements.course-nav', 'Canvas.placements.account-nav']
    end

  end
end
