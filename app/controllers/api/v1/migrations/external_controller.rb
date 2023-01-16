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
        # Expects:
        # { role: { :name,
        #            role_permissions: { :CreateRoom, :CanRecord, :ManageUsers, :ManageRoles, :ManageRooms, :ManageRecordings, :ManageSiteSettings }}}
        # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
        # Does: Creates a role.
        def create_role
          role_hash = role_params.to_h

          return render_data status: :created if Role.exists? name: role_hash[:name], provider: 'greenlight'

          role = Role.new(name: role_hash[:name], provider: 'greenlight')

          return render_error status: :bad_request unless role.save

          # Returns unless the Role has a RolePermission that differs from V3 default RolePermissions values
          return render_data status: :created unless role_hash[:role_permissions].any?

          # Finds all the RolePermissions that need to be updated
          role_permissions_temp = RolePermission.includes(:permission)
                                                .where(role_id: role.id, 'permissions.name': role_hash[:role_permissions].keys)
                                                .pluck(:id, :'permissions.name')
                                                .to_h
          # Re-structure the data so it is in the format: { <role_permission_id>: { value: <role_permission_new_value> } }
          role_permissions = role_permissions_temp.transform_values { |v| { value: role_hash[:role_permissions][v.to_sym] } }
          RolePermission.update!(role_permissions.keys, role_permissions.values)

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
        # Expects: { room: { :name, :friendly_id, :meeting_id, :last_session, :owner_email,
        #                    room_settings: { :record, :muteOnStart, :glAnyoneCanStart, :glAnyoneJoinAsModerator, :guestPolicy },
        #                    shared_users_emails: [ <list of shared users emails> ] }}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a Room and its RoomMeetingOptions.
        def create_room
          room_hash = room_params.to_h

          return render_data status: :created if Room.exists? friendly_id: room_hash[:friendly_id]

          user = User.find_by(email: room_hash[:owner_email], provider: 'greenlight')

          return render_error status: :bad_request unless user

          room = Room.new(room_hash.except(:owner_email, :room_settings, :shared_users_emails).merge({ user: }))

          # Redefines the validations method to do nothing
          # rubocop:disable Lint/EmptyBlock
          room.define_singleton_method(:set_friendly_id) {}
          room.define_singleton_method(:set_meeting_id) {}
          # rubocop:enable Lint/EmptyBlock

          return render_error status: :bad_request unless room.save

          # Finds all the RoomMeetingOptions that need to be updated
          room_meeting_options_temp = RoomMeetingOption.includes(:meeting_option)
                                                       .where(room_id: room.id, 'meeting_options.name': room_hash[:room_settings].keys)
                                                       .pluck(:id, :'meeting_options.name')
                                                       .to_h
          # Re-structure the data so it is in the format: { <room_meeting_option_id>: { value: <room_meeting_option_new_value> } }
          room_meeting_options = room_meeting_options_temp.transform_values { |v| { value: room_hash[:room_settings][v.to_sym] } }
          RoomMeetingOption.update!(room_meeting_options.keys, room_meeting_options.values)

          return render_data status: :created unless room_hash[:shared_users_emails].any?

          # Finds all the users that have a SharedAccess to the Room
          users_ids = User.where(email: room_hash[:shared_users_emails]).pluck(:id)
          # Re-structure the data so it is in the format: { { room_id:, user_id: } }
          shared_accesses = users_ids.map { |user_id| { room_id: room.id, user_id: } }
          SharedAccess.create!(shared_accesses)

          render_data status: :created
        end

        # POST /api/v1/migrations/site_settings.json
        # Expects: { settings: { site_settings: { :PrimaryColor, :PrimaryColorLight, :PrimaryColorDark,
        #                          :Terms, :PrivacyPolicy, :RegistrationMethod, :ShareRooms, :PreuploadPresentation },
        #                        room_configurations: { :record, :muteOnStart, :guestPolicy, :glAnyoneCanStart,
        #                          :glAnyoneJoinAsModerator, :glRequireAuthentication } } }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a SiteSettings or a RoomsConfiguration.
        def create_settings
          settings_hash = settings_params.to_h

          render_data status: :created unless settings_hash.any?

          # Finds all the SiteSettings that need to be updated
          site_settings_temp = SiteSetting.joins(:setting)
                                          .where('settings.name': settings_hash[:site_settings].keys, provider: 'greenlight')
                                          .pluck(:id, :'settings.name')
                                          .to_h
          # Re-structure the data so it is in the format: { <site_setting_id>: { value: <site_setting_new_value> } }
          site_settings = site_settings_temp.transform_values { |v| { value: settings_hash[:site_settings][v.to_sym] } }
          SiteSetting.update!(site_settings.keys, site_settings.values)

          # Finds all the RoomsConfiguration that need to be updated
          room_configurations_temp = RoomsConfiguration.joins(:meeting_option)
                                                       .where('meeting_options.name': settings_hash[:room_configurations].keys,
                                                              provider: 'greenlight')
                                                       .pluck(:id, :'meeting_options.name')
                                                       .to_h
          # Re-structure the data so it is in the format: { <rooms_configuration_id>: { value: <rooms_configuration_new_value> } }
          room_configurations = room_configurations_temp.transform_values { |v| { value: settings_hash[:room_configurations][v.to_sym] } }
          RoomsConfiguration.update!(room_configurations.keys, room_configurations.values)

          render_data status: :created
        end

        private

        def role_params
          decrypted_params.require(:role).permit(:name, role_permissions: {})
        end

        def user_params
          decrypted_params.require(:user).permit(:name, :email, :external_id, :language, :role)
        end

        def room_params
          decrypted_params.require(:room).permit(:name, :friendly_id, :meeting_id, :last_session, :owner_email, room_settings: {},
                                                                                                                shared_users_emails: [])
        end

        def settings_params
          decrypted_params.require(:settings).permit(site_settings: {}, room_configurations: {})
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
