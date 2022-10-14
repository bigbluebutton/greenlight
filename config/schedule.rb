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

# Permanently remove rooms that are longer than the specified period of time in the deleted state
every 1.days do
  max_deleted_time_env_var = 'MAX_DELETED_TIME_IN_DAYS'
  if ENV[max_deleted_time_env_var] && !ENV[max_deleted_time_env_var].strip.empty?
    max_deleted_time = ENV[max_deleted_time_env_var]
    LOG.info "Schedule job for the permanent removal of deleted rooms. The period of time in days for which "\
             "rooms that are marked as deleted in the database are kept before they are permanently removed is "\
             "#{max_deleted_time}"
    rake "room:permanently_remove_deleted_rooms[#{max_deleted_time}]"
  else
    LOG.info 'The job for the permanent removal of deleted rooms is not scheduled because the required '\
             'environment variable is not set'
  end
end

def notify_of_expiring_rooms(expiration_notification_term)
  expiration_notification_term_env_var = if expiration_notification_term == :LONG_TERM
    'TIME_IN_DAYS_TO_POTENTIAL_EXPIRATION_POINT_FOR_LONG_TERM_NOTIFICATION'
  else
    'TIME_IN_DAYS_TO_POTENTIAL_EXPIRATION_POINT_FOR_SHORT_TERM_NOTIFICATION'
  end
  expiration_time_env_var = 'EXPIRATION_TIME_IN_DAYS'
  room_expiration_last_despite_env_var = 'ROOM_EXPIRATION_LAST_DESPITE_IN_DAYS'
  room_expiration_notification_locale_env_var = 'LOCALE_FOR_ROOM_EXPIRATION_NOTIFICATION'

  if ENV[expiration_time_env_var] && !ENV[expiration_time_env_var].strip.empty? &&
     ENV[expiration_notification_term_env_var] &&
     !ENV[expiration_notification_term_env_var].strip.empty? &&
     ENV[room_expiration_last_despite_env_var] && !ENV[room_expiration_last_despite_env_var].strip.empty?
    expiration_time = ENV[expiration_time_env_var]
    expiration_notification_term_time = ENV[expiration_notification_term_env_var]
    expiration_last_despite = ENV[room_expiration_last_despite_env_var]
    log = "Schedule job for the periodic notification of expiring rooms. Expiration time in days is "\
          "#{expiration_time}, the time in days that is checked for rooms that potentially expire within that "\
          "period is #{expiration_notification_term_time}, the the last despite in days granted for already "\
          "expired rooms is #{expiration_last_despite}"

    if ENV[room_expiration_notification_locale_env_var] &&
       !ENV[room_expiration_notification_locale_env_var].strip.empty?
      expiration_notification_locale = ENV[room_expiration_notification_locale_env_var]
      LOG.info "#{log}, the fallback locale for the notification of expiring rooms is "\
               "#{expiration_notification_locale}"
      rake "room:notify_of_expiring_rooms[#{expiration_time},#{expiration_notification_term_time},"\
      "#{expiration_last_despite},#{expiration_notification_locale}]"
    else
      LOG.info log
      rake "room:notify_of_expiring_rooms[#{expiration_time},#{expiration_notification_term_time},"\
      "#{expiration_last_despite}]"
    end
  else
    LOG.info "The job for the notification of rooms that are going to expire within the "\
             "#{expiration_notification_term == :LONG_TERM ? 'long' : 'short'} term period is not scheduled because "\
             "the required environment variables are not set"
  end
end

# Notify of rooms that are going to expire within the specified long term period of time
every 1.days do
  notify_of_expiring_rooms(:LONG_TERM)
end

# Notify of rooms that are going to expire within the specified short term period of time
every 1.days do
  notify_of_expiring_rooms(:SHORT_TERM)
end
