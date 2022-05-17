# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.

      # POST /api/v1/users.json
      # Expects: { user: { :name, :email, :password, :password_confirmation } }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates and saves a new user record in the database with the provided parameters.

      def create
        # TODO: amir - ensure accessibility for unauthenticated requests only.
        user = User.new({ provider: 'greenlight' }.merge(user_params)) # TMP fix for presence validation of :provider
        if user.save
          session[:user_id] = user.id
          render_json status: :created
        else
          # TODO: amir - Improve logging.
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render_json status: :ok
        else
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      def destroy
        user = User.find(params[:id])
        if user.destroy
          render_json status: :ok
        else
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      def purge_avatar
        user = User.find(params[:id])
        user.avatar.purge
        if user.avatar.purge
          render_json status: :ok
        else
          render_json errors: user.errors.to_a, status: :bad_request
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
      end
    end
  end
end
