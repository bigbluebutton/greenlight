# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      # POST /api/v1/users.json (the json format is required for an explicit API)
      # Expects:
      #     params with the fallowing format: { user: { :name, :email, :password, :password_confirmation } }
      # Does:
      #     - Filters and validates the recieved params( throws ActionController::ParameterMissing for missed params).
      #     - Creates and saves a new user record in Users table with the provided parameters.
      #     - Returns json with the fallowig format : { msg: String, data: Array[serializable objects]
      #      ,errors: Array[String] }
      #     and status_code: 201 (created) | 400 (bad request).
      #         msg = response_msgs[:success] and errors = [] for successful save to db with status_code = 201.
      #         msg = response_msgs[:failed] and errors = user.errors.to_a for unsuccessfuly save to db
      #         with status_code = 400.
      def create
        user = User.new({ provider: 'greenlight' }.merge(user_params)) # TMP fix for presence validation of :provider
        if user.save
          render json: {
            msg: Rails.configuration.response_msgs[:success],
            data: [],
            errors: []
          }, status: :created
        else
          # TODO: amir - Improve logging.
          render json: {
            msg: Rails.configuration.response_msgs[:failed],
            data: [],
            errors: user.errors.to_a
          }, status: :bad_request
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
