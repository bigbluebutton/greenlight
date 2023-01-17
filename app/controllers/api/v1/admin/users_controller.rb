# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        before_action do
          ensure_authorized('ManageUsers')
        end

        # GET /api/v1/admin/users/:id.json
        # Updates the specified user's status
        def update
          user = User.find(params[:id])

          if user.update(user_params)
            render_data status: :ok
          else
            render_error errors: user.errors.to_a
          end
        end

        # GET /api/v1/admin/users/pending.json
        # Fetches the list of all users in the pending state
        def pending
          pending_users = User.includes(:role)
                              .with_provider(current_provider)
                              .where(status: 'pending')
                              .search(params[:search])

          pagy, pending_users = pagy(pending_users)

          render_data data: pending_users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        # GET /api/v1/admin/users/verified.json
        # Fetches all active users
        def verified
          sort_config = config_sorting(allowed_columns: %w[name roles.name])

          users = User.includes(:role)
                      .with_provider(current_provider)
                      .where(status: 'active')
                      .with_attached_avatar
                      .order(sort_config, created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        # GET /api/v1/admin/users/banned.json
        # Fetches all banned users
        def banned
          users = User.includes(:role)
                      .with_provider(current_provider)
                      .with_attached_avatar
                      .where(status: :banned)
                      .order(created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        private

        def user_params
          params.require(:user).permit(:status)
        end
      end
    end
  end
end
