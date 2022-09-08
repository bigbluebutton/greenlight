# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :room do
  desc "Removes all rooms for users that can't create rooms"
  task :remove, [:include_used] => :environment do |_task, args|
    roles = Role.where(role_permissions: { name: "can_create_rooms", value: "false" }).pluck(:name, :priority)
    other_roles = Role.where(role_permissions: { name: "can_create_rooms", value: "", enabled: "false" }).pluck(:name, :priority)

    roles_without_rooms = roles + other_roles
    roles_arr = []

    roles_without_rooms.each do |role|
      roles_arr << role[0]
    end

    users = User.with_role(roles_arr)
    users.each do |user|
      puts "  Destroying #{user.uid} rooms - role: #{user.role.name}"
      user.rooms.each do |room|
        if room.sessions.positive? && args[:include_used] != "true"
          puts yellow "   Skipping room #{room.uid}"
          next
        end

        begin
          room.destroy(true)
          puts green "    Destroying room #{room.uid}"
        rescue => e
          puts red "    Failed to remove room #{room.uid} - #{e}"
        end
      end
    end
  end

  task four: :environment do
    Room.all.each do |room|
      next if room.uid.split("-").length > 3

      begin
        new_uid = "#{room.uid}-#{SecureRandom.alphanumeric(3).downcase}"
        puts green "  Updating #{room.uid} to #{new_uid}"
        room.update_attributes(uid: new_uid)
      rescue => e
        puts red "    Failed to update #{room.uid} to #{new_uid} - #{e}"
      end
    end
  end

  desc "Delete rooms that were not used during the specified period of time or which exceeded their last despite"
  task :remove_expired_rooms, [:expiration_time_in_days] => :environment do |_task, args|
    logger = Rails.logger
    now = DateTime.now
    expired_rooms = get_expired_rooms(now, args[:expiration_time_in_days])
    expired_rooms
      .where("deletion_planned_at IS NULL")
      .or(expired_rooms.where.not("deletion_planned_at > ?", now))
      .destroy_all
    logger.debug("RAKE: Removed rooms not used within the last #{args[:expiration_time_in_days]} days")
  end

  desc "Inform users via E-Mail about rooms that will be deleted after the specified period of time because they will
 not have been used for the specified expiration time. If rooms are detected that are already expired and of which
 expiration the user was not notified yet, a last despite is granted"
  task :notify_of_expiring_rooms, [:expiration_time_in_days, :time_in_days_to_potential_expiration_point,
                                   :last_despite_in_days, :locale] => :environment do |_task, args|
    logger = Rails.logger
    args.with_defaults(locale: :en)
    raise ArgumentError, "The list of available locales does not include #{args[:locale]}" unless
      I18n.available_locales.include?(args[:locale])

    include Emailer
    @settings = if Rails.env.test? || !Rails.configuration.loadbalanced_configuration
                  Setting.includes(:features).find_by(provider: 'greenlight') || Setting.new
                else
                  Setting.new
                end

    # Date to check expiration for
    reference_date = DateTime.now + args[:time_in_days_to_potential_expiration_point].to_i.days
    potentially_expiring_rooms = get_expired_rooms(
      reference_date,
      args[:expiration_time_in_days],
      # Divide which rooms where already marked as going to expire soon during a check and which not
      Room.where(time_range_to_expiration_last_checked_in_days: nil).or(
        Room.where("time_range_to_expiration_last_checked_in_days > ?",
          args[:time_in_days_to_potential_expiration_point].to_i)
      )
    )

    owner_to_rooms = Hash.new([])
    potentially_expiring_rooms.each { |r| owner_to_rooms[r.owner] = [owner_to_rooms[r.owner], r].flatten }
    room_names_to_expiration_date = {}
    already_expired_room_ids = []
    potentially_expiring_rooms.each do |r|
      last_used_date = r.last_session || r.created_at
      expiration_date = r.deletion_planned_at || last_used_date + args[:expiration_time_in_days].to_i.days
      now = DateTime.now
      unless r.time_range_to_expiration_last_checked_in_days || expiration_date > now
        already_expired_room_ids.push(r.id)
        expiration_date = now + args[:last_despite_in_days].to_i.days
        r.update_attributes(deletion_planned_at: expiration_date)
      end
      room_names_to_expiration_date[r.name] = expiration_date
    end

    owner_to_rooms.each do |owner, rooms|
      room_names = rooms.map(&:name)
      logger.info("RAKE: Notify user '#{owner.name}' of the following rooms that are going to expire soon: #{
        room_names.map { |r| "'#{r}'" }.join(', ')}")
      send_upcoming_room_expiration_notification_email(
        owner,
        room_names,
        room_names_to_expiration_date.select { |r, _e| room_names.include?(r) },
        owner.language == 'default' ? args[:locale] : owner.language
      )
      rooms.each { |r|
        r.update_attributes(time_range_to_expiration_last_checked_in_days:
          if already_expired_room_ids.include?(r.id)
            args[:last_despite_in_days]
          else
            args[:time_in_days_to_potential_expiration_point]
          end)
      }
    end
  end

  def get_expired_rooms(date_to_check, expiration_time_in_days, rooms_to_check = nil)
    expiration_reference_date = date_to_check - expiration_time_in_days.to_i.days

    # Only include relevant rooms
    regular_rooms = rooms_to_check || Room
    # Exclude main rooms
    regular_rooms = regular_rooms.where.not(id: Room.select(:id).joins("INNER JOIN users ON rooms.id = users.room_id"))

    # Get expired rooms
    regular_rooms.where("last_session < ?", expiration_reference_date).or(
      # Get rooms that were never used and were created before the expiration reference date
      regular_rooms.where("last_session is null").where("created_at < ?", expiration_reference_date)
    )
  end
end
