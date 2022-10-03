# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        before_action only: %i[active_users] do
          ensure_authorized('ManageUsers')
        end

        def active_users
          sort_config = config_sorting(allowed_columns: %w[name roles.name])

          # TODO: Change to get active users only
          users = User.includes(:role)
                      .with_provider(current_provider)
                      .with_attached_avatar
                      .order(sort_config, role_id: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end
      end
    end
  end
end
