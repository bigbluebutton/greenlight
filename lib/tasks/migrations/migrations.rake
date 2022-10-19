# frozen_string_literal: true

namespace :migrations do
  COMMON = {
    headers: { "Content-Type" => "application/json" }
  }.freeze

  desc "Migrates v2 resources to v3"
  task :roles, [] => :environment do |_task, _args|
    has_encountred_issue = 0

    Role.select(:id, :name).where.not(name: Role::RESERVED_ROLE_NAMES).each do |r|
      params = { role: { name: r.name } }
      response = Net::HTTP.post(uri('roles'), payload(params), COMMON[:headers])

      case response
      when Net::HTTPCreated
        puts green "Succesfully migrated Role:"
        puts cyan "  ID: #{r.id}"
        puts cyan "  Name: #{r.name}"
      else
        puts red "Unable to migrate Role:"
        puts yellow "  ID: #{r.id}"
        puts yellow "  Name: #{r.name}"
        has_encountred_issue = 1 # At least one of the migrations failed.
      end
    end

    puts
    puts green "Roles migration complete."
    puts yellow "In case of an error please retry the process to resolve." unless has_encountred_issue.zero?
    exit has_encountred_issue
  end

  task :rooms, [] => :environment do |_task, _args|
    has_encountred_issue = 0

    # TODO: Optimize this by running in batches.
    Room.select(:uid, :name, :bbb_id, :last_session, :user_id).each do |r|
      params = { room: { friendly_id: r.uid, name: r.name, meeting_id: r.bbb_id, last_session: r.last_session, user_id: r.user_id } }
      response = Net::HTTP.post(uri('users'), payload(params), COMMON[:headers])

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
    unless Rails.configuration.v3_secret_key_base.present?
      raise red 'Unable to migrate: No "V3_SECRET_KEY_BASE" provided, please check your .env file.'
    end

    unless Rails.configuration.v3_secret_key_base.size >= 32
      raise red 'Unable to migrate: Provided "V3_SECRET_KEY_BASE" must be at least 32 charchters in length.'
    end

    key = Rails.configuration.v3_secret_key_base[0..31]
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_in: 10.seconds)
  end

  def uri(path)
    unless Rails.configuration.v3_endpoint.present?
      raise red 'Unable to migrate: No "V3_ENDPOINT" provided, please check your .env file.'
    end

    res = URI(Rails.configuration.v3_endpoint)
    res.path = "/api/v1/migrations/#{path}.json"
    res
  end

  def payload(params)
    res = { "v2" => { "encrypted_params" => encrypt_params(params) } }
    res.to_json
  end
end
