# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController
        before_action :find_user, only: :destroy

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

        def destroy
          # TODO: Will need to add additional logic later
          if @user.destroy
            render_data status: :ok
          else
            render_error errors: @user.errors.to_a
          end
        end

        def active_users
          # TODO: Change to get active users only
          users = User.with_attached_avatar.all.search(params[:search])

          render_data data: users, serializer: ServerUserSerializer, status: :ok
        end

        # POST /api/v1/admin/users/:user_id/create_server_room.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a server room for a given user.

        def create_server_room
          user = User.find params[:user_id]
          room = Room.create!(create_server_room_params.merge(user_id: user.id))

          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"
          render_data status: :created
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :language)
        end

        def create_server_room_params
          params.require(:room).permit(:name)
        end

        def find_user
          @user = User.find params[:id]
        end
      end
    end
  end
end
