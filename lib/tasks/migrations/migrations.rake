# frozen_string_literal: true

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
        .where.not(name: COMMON[:filtered_roles])
        .find_each(batch_size: COMMON[:batch_size]) do |r|
          params = { role: { name: r.name.capitalize } }
          response = Net::HTTP.post(uri('roles'), payload(params), COMMON[:headers])

          case response
          when Net::HTTPCreated
            puts green "Succesfully migrated Role:"
            puts cyan "  ID: #{r.id}"
            puts cyan "  Name: #{params[:role][:name]}"
          else
            puts red "Unable to migrate Role:"
            puts yellow "  ID: #{r.id}"
            puts yellow "  Name: #{params[:role][:name]}"
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
            puts yellow "  UID: #{u.uid}"
            puts yellow "  Name: #{params[:user][:name]}"
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

    Room.unscoped
        .select(:id, :uid, :name, :bbb_id, :last_session, :user_id)
        .includes(:owner)
        .where.not(users: { role_id: filtered_roles_ids, deleted: true }, deleted: true)
        .find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |r|
          params = { room: { friendly_id: r.uid,
                             name: r.name,
                             meeting_id: r.bbb_id,
                             last_session: r.last_session&.to_datetime,
                             owner_email: r.owner.email } }
          response = Net::HTTP.post(uri('rooms'), payload(params), COMMON[:headers])

          case response
          when Net::HTTPCreated
            puts green "Succesfully migrated Room:"
            puts cyan "  UID: #{r.uid}"
            puts cyan "  Name: #{r.name}"
          else
            puts red "Unable to migrate Room:"
            puts yellow "  UID: #{r.uid}"
            puts yellow "  Name: #{r.name}"
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

  task :room_settings, [:start, :stop] => :environment do |_task, args|
    start, stop = range(args)
    has_encountred_issue = 0

    filtered_roles_ids = Role.unscoped
                             .select(:id, :name)
                             .where(name: COMMON[:filtered_user_roles])
                             .pluck(:id)

    Room.unscoped
        .select(:uid, :room_settings)
        .where.not(users: { role_id: filtered_roles_ids, deleted: true }, deleted: true)
        .find_each(start: start, finish: stop, batch_size: COMMON[:batch_size]) do |r|

      parsed_room_settings = JSON.parse(r.room_settings)
      room_settings = {
        record: parsed_room_settings["recording"],
        muteOnStart: parsed_room_settings["muteOnStart"],
        guestPolicy: parsed_room_settings["requireModeratorApproval"],
        glAnyoneCanStart: parsed_room_settings["anyoneCanStart"],
        glAnyoneJoinAsModerator: parsed_room_settings["joinModerator"],
        glViewerAccessCode: r.access_code,
        glModeratorAccessCode: r.moderator_access_code
      }

      params = { room: { friendly_id: r.uid, room_settings: room_settings } }

      response = Net::HTTP.post(uri('room_meeting_option'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Succesfully migrated Room Settings for:"
        puts cyan "  UID: #{r.uid}"
      else
        puts red "Unable to migrate Room Settings for:"
        puts yellow "  UID: #{r.uid}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Room Settings migration completed."

    unless has_encountred_issue.zero?
      puts yellow "In case of an error please retry the process to resolve."
      puts yellow "If you have not migrated your users, kindly run 'rake migrations:room_settings' first and then retry."
    end

    exit has_encountred_issue
  end

  task site_settings: :environment do |_task|
    has_encountred_issue = 0

    params = { settings: { PrimaryColor: Rails.configuration.primary_color_default,
                                PrimaryColorLight: Rails.configuration.primary_color_lighten_default,
                                PrimaryColorDark: Rails.configuration.primary_color_darken_default,
                                # Terms: ,
                                # BrandingImage: ,
                                # PrivacyPolicy: ,
                                RegistrationMethod: Rails.configuration.registration_method_default,
                                ShareRooms: Rails.configuration.shared_access_default,
                                PreuploadPresentation: Rails.configuration.preupload_presentation_default } }

    response = Net::HTTP.post(uri('create_site_settings'), payload(params), COMMON[:headers])

    case response
    when Net::HTTPCreated
      puts green "Successfully migrated Site Settings"
    else
      puts red "Unable to migrate Site Settings"
      has_encountred_issue = 1 # At least one of the migrations failed.
    end

    puts
    puts green "Site Settings migration completed."

    unless has_encountred_issue.zero?
      puts yellow "In case of an error please retry the process to resolve."
      puts yellow "If you have not migrated your users, kindly run 'rake migrations:site_settings' first and then retry."
    end

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
end
