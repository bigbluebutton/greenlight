# frozen_string_literal: true
# rubocop:disable all

namespace :migrations do
  DEFAULT_ROLES_MAP = { "admin" => "Administrator", "user" => "User" }.freeze
  COMMON = {
    headers: { "Content-Type" => "application/json", "Accept" => "application/json" },
    batch_size: 500,
    filtered_roles: %w[admin user super_admin pending denied],
    filtered_user_roles: %w[super_admin pending denied]
  }.freeze

  desc "Migrates v2 resources to v3"
  task :roles, [:provider] => :environment do |_task, args|
    has_encountred_issue = 0

    roles = Role.unscoped
    roles = roles.where(provider: args[:provider]) if args[:provider].present?
    roles = roles.select(:id, :name, :provider)
                 .includes(:role_permissions)
                 .where.not(name: COMMON[:filtered_roles])

    roles.find_each(batch_size: COMMON[:batch_size]) do |r|
      # RolePermissions
      role_permissions_hash = r.role_permissions.pluck(:name, :value).to_h

      role_permissions = {
        CreateRoom: role_permissions_hash['can_create_rooms'] == "true" ? "true" : "false",
        CanRecord: role_permissions_hash['can_launch_recording'] == "true" ? "true" : "false",
        ManageUsers: role_permissions_hash['can_manage_users'] == "true" ? "true" : "false",
        ManageRoles: role_permissions_hash['can_edit_roles'] == "true" ? "true" : "false",
        # In V3, can_manage_room_recordings is split into two distinct permissions: ManageRooms and ManageRecordings
        ManageRooms: role_permissions_hash['can_manage_rooms_recordings'] == "true" ? "true" : "false",
        ManageRecordings: role_permissions_hash['can_manage_rooms_recordings'] == "true" ? "true" : "false",
        ManageSiteSettings: role_permissions_hash['can_edit_site_settings'] == "true" ? "true" : "false"
      }

      params = { role: { name: r.name.capitalize,
                         provider: r.provider,
                         role_permissions: role_permissions } }

      response = Net::HTTP.post(uri('roles'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Successfully migrated Role:"
        puts cyan "ID: #{r.id}"
        puts cyan "Name: #{params[:role][:name]}"
        puts cyan "Provider: #{params[:role][:provider]}"
      else
        puts red "Unable to migrate Role:"
        puts yellow "ID: #{r.id}"
        puts yellow "Name: #{params[:role][:name]}"
        puts yellow "Provider: #{params[:role][:provider]}"
        puts red "Errors: #{JSON.parse(response.body.to_s)['errors']}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Roles migration complete."
    puts yellow "In case of an error please retry the process to resolve." unless has_encountred_issue.zero?
    exit has_encountred_issue
  end

  task :users, [:provider, :start, :stop] => :environment do |_task, args|
    start, stop = range(args)
    has_encountred_issue = 0

    user = User.unscoped
    user = user.where(provider: args[:provider]) if args[:provider].present?
    user = user.select(:id, :uid, :name, :email,:password_digest, :social_uid, :language, :role_id, :created_at)
               .includes(:role)
               .where.not(roles: { name: COMMON[:filtered_user_roles] }, deleted: true)

    user.find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |u|
      role_name = infer_role_name(u.role.name)
      params = { user:
                   { name: u.name,
                     email: u.email,
                     external_id: u.social_uid,
                     password_digest: u.password_digest,
                     provider: u.provider,
                     language: u.language,
                     role: role_name,
                     created_at: u.created_at } }

      response = Net::HTTP.post(uri('users'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Successfully migrated User:"
        puts cyan "  UID: #{u.uid}"
        puts cyan "  Name: #{params[:user][:name]}"
        puts cyan "  Provider: #{params[:user][:provider]}"
      else
        puts red "Unable to migrate User:"
        puts yellow "UID: #{u.uid}"
        puts yellow "Name: #{params[:user][:name]}"
        puts yellow "Provider: #{params[:user][:provider]}"
        puts red "Errors: #{JSON.parse(response.body.to_s)['errors']}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Users migration completed."

    unless has_encountred_issue.zero?
      puts yellow "In case of an error please retry the process to resolve."
      puts yellow "If you have not migrated your roles, kindly run 'rake migrations:roles' first and then retry."
    end

    exit has_encountred_issue
  end

  task :rooms, [:provider, :start, :stop] => :environment do |_task, args|
    start, stop = range(args)
    has_encountred_issue = 0

    filtered_roles_ids = Role.unscoped
    filtered_roles_ids = filtered_roles_ids.where(provider: args[:provider]) if args[:provider].present?
    filtered_roles_ids = filtered_roles_ids.select(:id, :name)
                                           .where(name: COMMON[:filtered_user_roles])
                                           .pluck(:id)

    rooms = Room.unscoped
                .select(:id, :uid, :name, :bbb_id, :last_session, :user_id, :room_settings)
                .includes(:owner)
    rooms = rooms.where('users.provider': args[:provider]) if args[:provider].present?
    rooms = rooms.where.not(users: { role_id: filtered_roles_ids, deleted: true }, deleted: true)

    rooms.find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |r|
      # RoomSettings
      parsed_room_settings = JSON.parse(r.room_settings)
      # Returns nil if the RoomSetting value is the same as the corresponding default value in V3
      room_settings = if parsed_room_settings.empty? # Bypass Home Rome room_settings which is an empty hash by default
                        {}
                      else
                        {
                          record: parsed_room_settings["recording"] == true ? "true" : "false",
                          muteOnStart: parsed_room_settings["muteOnStart"] == true ? "true" : "false",
                          glAnyoneCanStart: parsed_room_settings["anyoneCanStart"] == true ? "true" : "false",
                          glAnyoneJoinAsModerator: parsed_room_settings["joinModerator"] == true ? "true" : "false",
                          guestPolicy: parsed_room_settings["requireModeratorApproval"] == true ? "ASK_MODERATOR" : "ALWAYS_ACCEPT",
                        }
                      end

      room_settings[:glViewerAccessCode] = r.access_code if r.access_code.present?
      room_settings[:glModeratorAccessCode] = r.moderator_access_code if r.moderator_access_code.present?

      shared_users_emails = r.shared_access.joins(:user).pluck(:'users.email')

      params = { room: { friendly_id: r.uid,
                         name: r.name,
                         meeting_id: r.bbb_id,
                         last_session: r.last_session&.to_datetime,
                         owner_email: r.owner.email,
                         provider: r.owner.provider,
                         room_settings: room_settings,
                         shared_users_emails: shared_users_emails } }
      if r.presentation.attached?
         begin
             params[:room][:presentation] = { blob: Base64.encode64(r.presentation.blob.download),
                                               filename: r.presentation.blob.filename.to_s }
         rescue Errno::ENOENT
             p "Failed to locate '#{r.presentation.blob.filename.to_s}' in active storage, skipping."
         end
      end
      response = Net::HTTP.post(uri('rooms'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Successfully migrated Room:"
        puts cyan "UID: #{r.uid}"
        puts cyan "Name: #{params[:room][:name]}"
        puts cyan "Provider: #{params[:room][:provider]}"
      else
        puts red "Unable to migrate Room:"
        puts yellow "UID: #{r.uid}"
        puts yellow "Name: #{params[:room][:name]}"
        puts yellow "Provider: #{params[:room][:provider]}"
        puts red "Errors: #{JSON.parse(response.body.to_s)['errors']}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Rooms migration completed."

    unless has_encountred_issue.zero?
      puts yellow "In case of an error please retry the process to resolve."
      puts yellow "If you have not migrated your users, kindly run 'rake migrations:users' first and then retry."
    end

    exit has_encountred_issue
  end

  task :settings, [:provider] => :environment do |_task, args|
    args.with_defaults(provider: "greenlight")
    has_encountred_issue = 0

    setting = Setting.includes(:features).find_by(provider: args[:provider])

    # SiteSettings
    site_settings = {
      PrimaryColor: setting.get_value('Primary Color'),
      PrimaryColorLight: setting.get_value('Primary Color Lighten'),
      Terms: setting.get_value('Legal URL'),
      PrivacyPolicy: setting.get_value('Privacy Policy URL'),
      RegistrationMethod: infer_registration_method(setting.get_value('Registration Method')),
      ShareRooms: setting.get_value('Shared Access'),
      PreuploadPresentation: setting.get_value('Preupload Presentation'),
    }.compact


    # Sets Record to default_enabled in V3 if set to optional in V2
    rooms_config_record_value = if setting.get_value("Require Recording Consent") != "true"
      "true"
    else
      infer_room_config_value(setting.get_value('Room Configuration Recording'))
    end

    # RoomConfigurations
    rooms_configurations = {
      record: rooms_config_record_value == "optional" ? "default_enabled" : rooms_config_record_value,
      muteOnStart: infer_room_config_value(setting.get_value('Room Configuration Mute On Join')),
      guestPolicy: infer_room_config_value(setting.get_value('Room Configuration Require Moderator')),
      glAnyoneCanStart: infer_room_config_value(setting.get_value('Room Configuration Allow Any Start')),
      glAnyoneJoinAsModerator: infer_room_config_value(setting.get_value('Room Configuration All Join Moderator')),
      glRequireAuthentication: infer_room_config_value(setting.get_value('Room Authentication'))
    }.compact

    params = { settings: { provider: args[:provider], site_settings: site_settings, rooms_configurations: rooms_configurations } }

    response = Net::HTTP.post(uri('settings'), payload(params), COMMON[:headers])

    case response
    when Net::HTTPCreated
      puts green "Successfully migrated Site Settings"
      puts cyan "Provider: #{args[:provider]}"
      site_settings.each do |setting|
        puts cyan "#{setting[0]}: #{setting[1]}"
      end
      puts green "Successfully migrated Rooms Configurations"
      rooms_configurations.each do |rooms_config|
        puts cyan "#{rooms_config[0]}: #{rooms_config[1]}"
      end
    else
      puts red "Unable to migrate Settings"
      puts red "Provider: #{args[:provider]}"
      puts red "Errors: #{JSON.parse(response.body.to_s)['errors']}"
      has_encountred_issue = 1 # At least one of the migrations failed.
    end

    puts
    puts green "Settings migration completed."

    puts yellow "In case of an error please retry the process to resolve." unless has_encountred_issue.zero?

    exit has_encountred_issue
  end

  private

  def encrypt_params(params)
    unless ENV["V3_SECRET_KEY_BASE"].present?
      raise red 'Unable to migrate: No "V3_SECRET_KEY_BASE" provided, please check your .env file.'
    end

    unless ENV["V3_SECRET_KEY_BASE"].size >= 32
      raise red 'Unable to migrate: Provided "V3_SECRET_KEY_BASE" must be at least 32 characters in length.'
    end

    key = ENV["V3_SECRET_KEY_BASE"][0..31]
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_in: 10.seconds)
  end

  def uri(path)
    raise red 'Unable to migrate: No "V3_ENDPOINT" provided, please check your .env file.' unless ENV["V3_ENDPOINT"].present?

    base_uri = URI(ENV["V3_ENDPOINT"])
    res = URI::join(base_uri, "api/v1/migrations/#{path}.json")
    res
  end

  def payload(params)
    res = { "v2" => { "encrypted_params" => encrypt_params(params) } }
    res.to_json
  end

  def range(args)
    start = args[:start].to_i
    start = 1 unless start.positive?

    stop = args[:stop].to_i
    stop = nil unless stop.positive?

    raise red "Unable to migrate: Invalid provided range [start: #{start}, finish: #{stop}]" if stop && start > stop

    [start, stop]
  end

  def infer_role_name(name)
    DEFAULT_ROLES_MAP[name] || name.capitalize
  end

  # Registration Method returns "0", "1" or "2" but V3 expects "open", "invite" or "approval"
  def infer_registration_method(registration_method)
    case registration_method
    when "1"
      "invite"
    when "2"
      "approval"
    else
      "open"
    end
  end

  def infer_room_config_value(config_val)
    return nil unless config_val.present?

    case config_val
      when "enabled"
        "true"
      when "disabled"
        "false"
      when "true"
        "true"
      else
        "optional"
      end
  end
end
