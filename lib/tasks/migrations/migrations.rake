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

  task :users, [] => :environment do |_task, _args|
    has_encountred_issue = 0

    # TODO: Optimize this by running in batches.
    User.select(:id, :uid, :name, :email, :social_uid, :language, :role_id).each do |u|
      params = { user: { name: u.name, email: u.email, external_id: u.social_uid, language: u.language, role: u.role.name } }
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
