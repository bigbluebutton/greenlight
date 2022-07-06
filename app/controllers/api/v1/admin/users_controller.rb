# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
         # TODO: amir - Revisit this.
        before_action :find_user, only: :create_server_room

        include Avatarable

        def create
          # TODO: amir - ensure accessibility for unauthenticated requests only.
          params[:user][:language] = I18n.default_locale if params[:user][:language].blank?

          user = User.new({
            provider: 'greenlight',
            role: Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
          }.merge(user_params)) # TMP fix for presence validation of :provider

          if user.save
            render_data status: :created
          else
            # TODO: amir - Improve logging.
            render_error errors: user.errors.to_a, status: :bad_request
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

        # POST /api/v1/admin/users/:user_id/create_server_room.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a server room for a given user.

        def create_server_room
          room = Room.create!(create_server_room_params.merge(user_id: @user.id))

          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"
          render_json status: :created
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :language)
        end

        def create_server_room_params
          params.require(:room).permit(:name)
        end

        def find_user
          @user = User.find params[:user_id]
        end
      end
    end
  end
end
