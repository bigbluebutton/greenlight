# frozen_string_literal: true

namespace :migrations do
  DEFAULT_ROLES_MAP = { "admin" => "Administrator", "user" => "User" }.freeze
  COMMON = {
    headers: { "Content-Type" => "application/json" },
    batch_size: 500,
  }.freeze

  desc "Migrates v2 resources to v3"
  task :roles, [] => :environment do |_task, _args|
    has_encountred_issue = 0

    Role.select(:id, :name)
        .where.not(name: Role::RESERVED_ROLE_NAMES)
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

    User.select(:id, :uid, :name, :email, :social_uid, :language, :role_id)
        .joins(:role)
        .where.not(roles: { name: %w[super_admin pending denied] }, deleted: true)
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

    filtered_roles_ids = Role.where(name: %w[super_admin pending denied]).pluck(:id).uniq

    Room.select(:id, :uid, :name, :bbb_id, :last_session, :user_id)
        .joins(:owner)
        .where.not(users: { role_id: filtered_roles_ids, deleted: true })
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
