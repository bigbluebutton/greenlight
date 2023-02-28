# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity

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

          return render_error(status: :bad_request, errors: role&.errors&.to_a) unless role.save

          # Returns unless the Role has a RolePermission that differs from V3 default RolePermissions values
          return render_data status: :created unless role_hash[:role_permissions].any?

          # Finds all the RolePermissions that need to be updated
          role_permissions_joined = RolePermission.includes(:permission)
                                                  .where(role_id: role.id, 'permissions.name': role_hash[:role_permissions].keys)

          okay = true
          role_permissions_joined.each do |role_permission|
            permission_name = role_permission.permission.name
            okay = false unless role_permission.update(value: role_hash[:role_permissions][permission_name])
          end

          return render_error status: :bad_request, errors: 'Something went wrong when migrating the role permissions.' unless okay

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

          return render_error(status: :bad_request, errors: 'The user role does not exist.') unless role

          user_hash[:password] = generate_secure_pwd if user_hash[:external_id].blank?

          user = User.new(user_hash.merge(verified: true, provider: 'greenlight', role:))

          return render_error(status: :bad_request, errors: user&.errors&.to_a) unless user.save

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

          return render_error(status: :bad_request, errors: 'The room owner does not exist.') unless user

          room = Room.new(room_hash.except(:owner_email, :room_settings, :shared_users_emails).merge({ user: }))

          # Redefines the validations method to do nothing
          # rubocop:disable Lint/EmptyBlock
          room.define_singleton_method(:set_friendly_id) {}
          room.define_singleton_method(:set_meeting_id) {}
          # rubocop:enable Lint/EmptyBlock

          return render_error(status: :bad_request, errors: room&.errors&.to_a) unless room.save

          if room_hash[:room_settings].any?
            # Finds all the RoomMeetingOptions that need to be updated
            room_meeting_options_joined = RoomMeetingOption.includes(:meeting_option)
                                                           .where(room_id: room.id, 'meeting_options.name': room_hash[:room_settings].keys)

            okay = true
            room_meeting_options_joined.each do |room_meeting_option|
              option_name = room_meeting_option.meeting_option.name
              okay = false unless room_meeting_option.update(value: room_hash[:room_settings][option_name])
            end

            return render_error status: :bad_request, errors: 'Something went wrong when migrating the room settings.' unless okay
          end

          return render_data status: :created unless room_hash[:shared_users_emails].any?

          # Finds all the users that have a SharedAccess to the Room
          shared_with_users = User.where(email: room_hash[:shared_users_emails])

          okay = true
          shared_with_users.each do |shared_with_user|
            okay = false unless SharedAccess.new(room_id: room.id, user_id: shared_with_user.id).save
          end

          return render_error status: :bad_request, errors: 'Something went wrong when sharing the room.' unless okay

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
          site_settings_joined = SiteSetting.joins(:setting)
                                            .where('settings.name': settings_hash[:site_settings].keys, provider: 'greenlight')

          okay = true
          site_settings_joined.each do |site_setting|
            site_setting_name = site_setting.setting.name
            okay = false unless site_setting.update(value: settings_hash[:site_settings][site_setting_name])
          end

          return render_error status: :bad_request, errors: 'Something went wrong when migrating site settings.' unless okay

          # Finds all the RoomsConfiguration that need to be updated
          room_configurations_joined = RoomsConfiguration.joins(:meeting_option)
                                                         .where('meeting_options.name': settings_hash[:room_configurations].keys,
                                                                provider: 'greenlight')

          okay = true
          room_configurations_joined.each do |room_configuration|
            room_configuration_name = room_configuration.meeting_option.name
            okay = false unless room_configuration.update(value: settings_hash[:room_configurations][room_configuration_name])
          end

          return render_error status: :bad_request, errors: 'Something went wrong when migrating room configurations.' unless okay

          render_data status: :created
        end

        private

        def role_params
          decrypted_params.require(:role).permit(:name,
                                                 role_permissions: %w[CreateRoom CanRecord ManageUsers ManageRoles ManageRooms ManageRecordings
                                                                      ManageSiteSettings])
        end

        def user_params
          decrypted_params.require(:user).permit(:name, :email, :external_id, :language, :role)
        end

        def room_params
          decrypted_params.require(:room).permit(:name, :friendly_id, :meeting_id, :last_session, :owner_email,
                                                 shared_users_emails: [],
                                                 room_settings: %w[record muteOnStart guestPolicy glAnyoneCanStart glAnyoneJoinAsModerator])
        end

        def settings_params
          decrypted_params.require(:settings).permit(site_settings: %w[PrimaryColor PrimaryColorLight Terms PrivacyPolicy RegistrationMethod
                                                                       ShareRooms PreuploadPresentation],
                                                     room_configurations: %w[record muteOnStart guestPolicy glAnyoneCanStart glAnyoneJoinAsModerator
                                                                             glRequireAuthentication])
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
# rubocop:enable Metrics/PerceivedComplexity
