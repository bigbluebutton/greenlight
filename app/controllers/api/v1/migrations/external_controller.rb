# frozen_string_literal: true

module Api
  module V1
    module Migrations
      class ExternalController < ApiController
        include ClientRoutable
        CHARS = {
          degits: [*'0'..'9'],
          lower_letters: [*'a'..'z'],
          upper_letters: [*'A'..'Z'],
          symbols: [*' '..'/', *'{'..'~']
        }.freeze

        skip_before_action :verify_authenticity_token
        skip_before_action :ensure_authenticated

        rescue_from ActiveSupport::MessageEncryptor::InvalidMessage do |exception|
          log_exception exception
          render_error errors: [Rails.configuration.custom_error_msgs[:missing_params]], status: :bad_request
        end

        # POST /api/v1/migrations/roles.json
        # Expects: { role: { :name } }
        # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
        # Does: Creates a role.
        def create_role
          role_hash = role_params.to_h

          return render_data status: :created if Role.exists? name: role_hash[:name], provider: 'greenlight'

          role = Role.new role_hash.merge(provider: 'greenlight')

          return render_error status: :bad_request unless role.save

          render_data status: :created
        end

        # POST /api/v1/migrations/users.json
        # Expects: { user: { :name, :email, :external_id, :language, :role } }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a user.

        def create_user
          user_hash = user_params.to_h

          return render_data status: :created if User.exists? email: user_hash[:email], provider: 'greenlight'

          user_hash[:language] = I18n.default_locale if user_hash[:language].blank? || user_hash[:language] == 'default'

          role = Role.find_by(name: user_hash[:role], provider: 'greenlight')

          return render_error status: :bad_request unless role

          user_hash[:password] = generate_secure_pwd if user_hash[:external_id].blank?

          user = User.new(user_hash.merge(provider: 'greenlight', role:))
          return render_error status: :bad_request unless user.save

          return render_data status: :created if user.external_id?

          token = user.generate_reset_token!

          UserMailer.with(user:, expires_in: User::RESET_TOKEN_VALIDITY_PERIOD.from_now,
                          reset_url: reset_password_url(token)).reset_password_email.deliver_later

          render_data status: :created
        end

        # POST /api/v1/migrations/rooms.json
        # Expects: { room: { :name, :friendly_id, :meeting_id, :last_session } }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a room.
        def create_room
          room_hash = room_params.to_h

          return render_data status: :created if Room.exists? friendly_id: room_hash[:friendly_id]

          user = User.find_by(email: room_hash[:owner_email], provider: 'greenlight')

          return render_error status: :bad_request unless user

          room = Room.new(room_hash.except(:owner_email, :owner_provider).merge({ user: }))

          # Redefines the validations method to do nothing
          # rubocop:disable Lint/EmptyBlock
          room.define_singleton_method(:set_friendly_id) {}
          room.define_singleton_method(:set_meeting_id) {}
          # rubocop:enable Lint/EmptyBlock

          return render_error status: :bad_request unless room.save

          render_data status: :created
        end

        private

        def role_params
          decrypted_params.require(:role).permit(:name)
        end

        def user_params
          decrypted_params.require(:user).permit(:name, :email, :external_id, :language, :role)
        end

        def room_params
          decrypted_params.require(:room).permit(:name, :friendly_id, :meeting_id, :last_session, :owner_email)
        end

        def decrypted_params
          return @decrypted_params unless @decrypted_params.nil?

          encrypted_params = params.require(:v2).require(:encrypted_params)

          raise ActiveSupport::MessageEncryptor::InvalidMessage unless encrypted_params.is_a? String

          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], cipher: 'aes-256-gcm', serializer: Marshal)
          decrypted_params = crypt.decrypt_and_verify(encrypted_params) || {}

          raise ActiveSupport::MessageEncryptor::InvalidMessage unless decrypted_params.is_a? Hash

          @decrypted_params = ActionController::Parameters.new(decrypted_params)
        end

        def generate_secure_pwd
          base = SecureRandom.alphanumeric(22)
          extra = [
            CHARS[:degits].sample(random: SecureRandom), CHARS[:symbols].sample(random: SecureRandom),
            CHARS[:lower_letters].sample(random: SecureRandom), CHARS[:upper_letters].sample(random: SecureRandom)
          ].shuffle(random: SecureRandom)

          base[0..5] + extra.first + base[6..11] + extra.second + base[12..17] + extra.third + base[18..21] + extra.fourth
        end
      end
    end
  end
end
