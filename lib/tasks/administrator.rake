# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :admin do
  desc "Creates an administrator account"
  # added first name and lastname
  task :create, [:firstname, :lastname, :email, :mobile, :password, :role] => :environment do |_task, args|
    Rake::Task["user:create"].invoke(args[:firstname], args[:lastname], args[:email], args[:mobile], args[:password], "admin")
  end
end
