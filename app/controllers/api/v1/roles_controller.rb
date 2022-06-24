# frozen_string_literal: true

module Api
  module V1
    class RolesController < ApiController
      skip_before_action :verify_authenticity_token
    end
  end
end
