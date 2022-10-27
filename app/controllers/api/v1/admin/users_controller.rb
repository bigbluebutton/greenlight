# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        before_action only: %i[verified_users pending update] do
          ensure_authorized('ManageUsers')
        end

        def verified_users
          sort_config = config_sorting(allowed_columns: %w[name roles.name])

          # TODO: Change to get verified users only
          users = User.includes(:role)
                      .with_provider(current_provider)
                      .where(status: 'active')
                      .with_attached_avatar
                      .order(sort_config, created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        def banned_users
          sort_config = config_sorting(allowed_columns: %w[name roles.name])
          # getting all the users who have a banned status
          users = User.includes(:role)
                      .with_provider(current_provider)
                      .with_attached_avatar
                      .where(status: :banned)
                      .order(sort_config, created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        def pending
          pending_users = User.includes(:role)
                              .with_provider(current_provider)
                              .where(status: 'pending')
                              .search(params[:search])

          pagy, pending_users = pagy(pending_users)

          render_data data: pending_users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        def update
          user = User.find(params[:id])

          if user.update(user_params)
            render_data status: :ok
          else
            render_error errors: user.errors.to_a
          end
        end

        private

        def user_params
          params.require(:user).permit(:status)
        end
      end
    end
  end
end
