# frozen_string_literal: true

require_relative 'task_helpers'

namespace :user do
  desc 'Create a user'
  task :create, %i[name email password role verified status language] => :environment do |_task, args|
    # Default values.
    u = {
      role: 'User',
      verified: false,
      status: :active,
      language: I18n.default_locale
    }.merge(args)

    u[:provider] = 'greenlight'

    filter_values!(user: u)
    u = User.new(u)

    display_user_errors(user: u) unless u.save

    success 'User account was created successfully!'
    info "  Name: #{u.name}"
    info "  Email: #{u.email}"
    info "  Password: #{u.password}"
    info "  Role: #{u.role.name}"
    info "  Verified: #{u.verified}"
    info "  Status: #{u.status}"
    info "  Language: #{u.language}"

    exit 0
  end

  private

  def filter_values!(user:)
    roles_black_list = %w[SuperAdmin]
    role_name = user[:role]
    role_name = SettingGetter.new(setting_name: 'DefaultRole', provider: 'greenlight').call if roles_black_list.include?(user[:role])

    user[:role] = Role.find_by(name: role_name, provider: 'greenlight')
    return if user[:role]

    warning "Unable to create user: '#{user[:name]}'"
    err "   Role '#{role_name}' does not exist, maybe you have not run the DB migrations?"
  end

  def display_user_errors(user:)
    warning "Unable to create user: '#{user.name}'"
    err "   Failed to pass the following validations: #{user.errors.to_a}"
  end
end
