# frozen_string_literal: true

require_relative 'task_helpers'

namespace :user do
  desc 'Create a user'
  task :create, %i[name email password role] => :environment do |_task, args|
    # Default values.
    user = {
      provider: 'greenlight',
      verified: true,
      status: :active,
      language: I18n.default_locale
    }.merge(args)

    user[:role] = SettingGetter.new(setting_name: 'DefaultRole', provider: 'greenlight').call if user[:role].blank?

    check_role!(user:)
    user = User.new(user)

    display_user_errors(user:) unless user.save

    success 'User account was created successfully!'
    info "  Name: #{user.name}"
    info "  Email: #{user.email}"
    info "  Password: #{user.password}"
    info "  Role: #{user.role.name}"
    info "  Verified: #{user.verified}"
    info "  Status: #{user.status}"
    info "  Language: #{user.language}"

    exit 0
  end

  private

  def check_role!(user:)
    role_name = user[:role]
    user[:role] = Role.find_by(name: role_name, provider: 'greenlight')
    return if user[:role]

    warning "Unable to create user: '#{user[:name]}'"
    err "   Role '#{role_name}' does not exist, maybe you have not run the DB migrations?"
  end

  def display_user_errors(user:)
    warning "Unable to create user: '#{user.name}'"
    err "   Failed to pass the following validations:\n    #{user.errors.to_a}"
  end
end
