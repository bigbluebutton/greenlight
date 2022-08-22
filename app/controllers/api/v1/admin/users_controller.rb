# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        before_action only: %i[active_users] do
          ensure_authorized('ManageUsers')
        end

        def active_users
          # TODO: Change to get active users only
          users = User.with_provider(current_provider).with_attached_avatar.search(params[:search])

          pagy, users = pagy_array(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: ServerUserSerializer, status: :ok
        end
      end
    end
  end
end
