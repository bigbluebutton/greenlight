# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require 'logger'

LOG = Logger.new(File.open("#{Dir.pwd}/log/whenever.log", 'a'))
LOG.formatter = proc do |severity, datetime, _progname, msg|
  puts msg
  "#{datetime} - #{severity}: #{msg} \n"
end

# Delete rooms not used for the specified period of time
every 1.days do
  expiration_time_env_var = 'EXPIRATION_TIME_IN_DAYS'
  if ENV[expiration_time_env_var] && !ENV[expiration_time_env_var].strip.empty?
    expiration_time = ENV[expiration_time_env_var]
    LOG.info "Schedule job for the periodic deletion of expired rooms. Expiration time in days is "\
             "#{expiration_time}"
    rake "room:remove_expired_rooms[#{expiration_time}]"
  else
    LOG.info 'The job for the deletion of expired rooms is not scheduled because the required environment '\
             'variable is not set'
  end
end
