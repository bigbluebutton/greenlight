# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      # POST /api/v1/users.json
      # Expects: { user: { :name, :email, :password, :password_confirmation } }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates and saves a new user record in the database with the provided parameters.

      def create
        user = User.new({ provider: 'greenlight' }.merge(user_params)) # TMP fix for presence validation of :provider
        if user.save
          render json: {
            data: [],
            errors: []
          }, status: :created
        else
          # TODO: amir - Improve logging.
          render json: {
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
