# frozen_string_literal: true
# rubocop:disable all

namespace :migrations do
  DEFAULT_ROLES_MAP = { "admin" => "Administrator", "user" => "User" }.freeze
  COMMON = {
    headers: { "Content-Type" => "application/json" },
    batch_size: 500,
    filtered_roles: %w[super_admin admin pending denied user],
    filtered_user_roles: %w[super_admin pending denied]
  }.freeze

  desc "Migrates v2 resources to v3"
  task :roles, [] => :environment do |_task, _args|
    has_encountred_issue = 0

    Role.unscoped
        .select(:id, :name)
        .includes(:role_permissions)
        .where.not(name: COMMON[:filtered_roles])
        .find_each(batch_size: COMMON[:batch_size]) do |r|
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
                         role_permissions: role_permissions } }

      response = Net::HTTP.post(uri('roles'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Succesfully migrated Role:"
        puts cyan "ID: #{r.id}"
        puts cyan "Name: #{params[:role][:name]}"
      else
        puts red "Unable to migrate Role:"
        puts yellow "ID: #{r.id}"
        puts yellow "Name: #{params[:role][:name]}"
        puts red "Errors: #{JSON.parse(response.body.to_s)['errors']}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Roles migration complete."
    puts yellow "In case of an error please retry the process to resolve." unless has_encountred_issue.zero?
    exit has_encountred_issue
  end

  task :users, [:start, :stop] => :environment do |_task, args|
    start, stop = range(args)
    has_encountred_issue = 0

    User.unscoped
        .select(:id, :uid, :name, :email, :social_uid, :language, :role_id)
        .includes(:role)
        .where.not(roles: { name: COMMON[:filtered_user_roles] }, deleted: true)
        .find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |u|
      role_name = infer_role_name(u.role.name)
      params = { user: { name: u.name, email: u.email, external_id: u.social_uid, language: u.language, role: role_name } }

      response = Net::HTTP.post(uri('users'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Succesfully migrated User:"
        puts cyan "  UID: #{u.uid}"
        puts cyan "  Name: #{params[:user][:name]}"
      else
        puts red "Unable to migrate User:"
        puts yellow "UID: #{u.uid}"
        puts yellow "Name: #{params[:user][:name]}"
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

  task :rooms, [:start, :stop] => :environment do |_task, args|
    start, stop = range(args)
    has_encountred_issue = 0

    filtered_roles_ids = Role.unscoped
                             .select(:id, :name)
                             .where(name: COMMON[:filtered_user_roles])
                             .pluck(:id)

    Room.unscoped.select(:id, :uid, :name, :bbb_id, :last_session, :user_id, :room_settings)
        .includes(:owner)
        .where.not(users: { role_id: filtered_roles_ids, deleted: true }, deleted: true)
        .find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |r|
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
                          guestPolicy: parsed_room_settings["requireModeratorApproval"] == true ? "ASK_MODERATOR" : "ALWAYS_ACCEPT"
                        }
                      end

      shared_users_emails = r.shared_access.joins(:user).pluck(:'users.email')

      params = { room: { friendly_id: r.uid,
                         name: r.name,
                         meeting_id: r.bbb_id,
                         last_session: r.last_session&.to_datetime,
                         owner_email: r.owner.email,
                         room_settings: room_settings,
                         shared_users_emails: shared_users_emails } }

      response = Net::HTTP.post(uri('rooms'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Succesfully migrated Room:"
        puts cyan "UID: #{r.uid}"
        puts cyan "Name: #{r.name}"
      else
        puts red "Unable to migrate Room:"
        puts yellow "UID: #{r.uid}"
        puts yellow "Name: #{r.name}"
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

  task settings: :environment do |_task|
    has_encountred_issue = 0

    settings_hash = Setting.find_by(provider: 'greenlight').features.pluck(:name, :value).to_h

    # SiteSettings
    site_settings = {
      PrimaryColor: settings_hash['Primary Color'],
      PrimaryColorLight: settings_hash['Primary Color Lighten'],
      Terms: settings_hash['Legal URL'],
      PrivacyPolicy: settings_hash['Privacy Policy URL'],
      RegistrationMethod: infer_registration_method(settings_hash['Registration Method']),
      ShareRooms: settings_hash['Shared Access'],
      PreuploadPresentation: settings_hash['Preupload Presentation'],
    }.compact

    # RoomConfigurations
    room_configurations = {
      record: infer_room_config_value(settings_hash['Room Configuration Recording']),
      muteOnStart: infer_room_config_value(settings_hash['Room Configuration Mute On Join']),
      guestPolicy: infer_room_config_value(settings_hash['Room Configuration Require Moderator']),
      glAnyoneCanStart: infer_room_config_value(settings_hash['Room Configuration Allow Any Start']),
      glAnyoneJoinAsModerator: infer_room_config_value(settings_hash['Room Configuration All Join Moderator']),
      glRequireAuthentication: infer_room_config_value(settings_hash['Room Authentication'])
    }.compact

    params = { settings: { site_settings: site_settings, room_configurations: room_configurations } }

    response = Net::HTTP.post(uri('settings'), payload(params), COMMON[:headers])

    case response
    when Net::HTTPCreated
      puts green "Successfully migrated Settings"
    else
      puts red "Unable to migrate Settings"
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
      raise red 'Unable to migrate: Provided "V3_SECRET_KEY_BASE" must be at least 32 charchters in length.'
    end

    key = ENV["V3_SECRET_KEY_BASE"][0..31]
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_in: 10.seconds)
  end

  def uri(path)
    raise red 'Unable to migrate: No "V3_ENDPOINT" provided, please check your .env file.' unless ENV["V3_ENDPOINT"].present?

    res = URI(ENV["V3_ENDPOINT"])
    res.path = "/api/v1/migrations/#{path}.json"
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
      when "true"
        "true"
      when "disabled"
        "false"
      else
        "optional"
      end 
  end
end
