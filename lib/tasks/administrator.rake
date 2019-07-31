# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :admin do
  desc "Creates an administrator account"
  task :create, [:name, :email, :password, :role] => :environment do |_task, args|
    Rake::Task["user:create"].invoke(args[:name], args[:email], args[:password], "admin")
  end
end
