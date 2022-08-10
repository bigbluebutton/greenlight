# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        include Avatarable

        before_action only: %i[active_users] do
          ensure_authorized('ManageUsers')
        end

        def active_users
          # TODO: Change to get active users only
          pagy, users = pagy_array(User.with_attached_avatar.all.search(params[:search]))

          render_data data: users, meta: pagy_metadata(pagy), serializer: ServerUserSerializer, status: :ok
        end
      end
    end
  end
end
