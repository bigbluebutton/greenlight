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

  desc "Delete rooms that were not used during the specified period of time"
  task :remove_expired_rooms, [:expiration_time_in_days] => :environment do |_task, args|
    # Exclude main rooms
    regular_rooms = Room.where.not(id: Room.select(:id).joins("INNER JOIN users ON rooms.id = users.room_id"))

    # Delete expired rooms
    regular_rooms.where("last_session < ?", args[:expiration_time_in_days].to_i.days.ago)
                 .destroy_all
    # Delete rooms that were never used
    regular_rooms.where("last_session is null")
                 .where("updated_at < ?", args[:expiration_time_in_days].to_i.days.ago)
                 .destroy_all
    Rails.logger.info("RAKE: Removed rooms not used within the last #{args[:expiration_time_in_days]} days")
  end
end
