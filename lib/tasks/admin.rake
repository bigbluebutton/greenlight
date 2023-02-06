# frozen_string_literal: true

require_relative 'task_helpers'

namespace :admin do
  desc 'Create an administrator account'
  task :create, %i[name email password] => :environment do |_task, args|
    # Default values.
    admin = {
      name: 'Administrator',
      email: 'admin@example.com',
      password: 'Administrator1!'
    }.merge(args)

    Rake::Task['user:create'].invoke(admin[:name], admin[:email], admin[:password], 'Administrator')

    exit 0
  end
end
