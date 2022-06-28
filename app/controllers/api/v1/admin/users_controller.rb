# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.

        include Avatarable

        def create
          # TODO: amir - ensure accessibility for unauthenticated requests only.
          params[:user][:language] = I18n.default_locale if params[:user][:language].blank?

          user = User.new({
            provider: 'greenlight',
            role: Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
          }.merge(user_params)) # TMP fix for presence validation of :provider

          if user.save
            render_json status: :created
          else
            # TODO: amir - Improve logging.
            render_json errors: user.errors.to_a, status: :bad_request
          end
        end

        def active_users
          # TODO: Change to get active users only
          users = User.all.search(params[:search])

          users.map! do |user|
            {
              id: user.id,
              name: user.name,
              email: user.email,
              provider: user.provider,
              role: user.role.name,
              created_at: user.created_at.strftime('%A %B %e, %Y'),
              avatar: user_avatar(user)
            }
          end

          render_json data: users, status: :ok
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :language)
        end
      end
    end
  end
end
