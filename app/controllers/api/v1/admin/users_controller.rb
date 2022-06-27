# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        include Avatarable

        def active_users
          # TODO: Change to get active users only
          users = User.all.to_a

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
      end
    end
  end
end
