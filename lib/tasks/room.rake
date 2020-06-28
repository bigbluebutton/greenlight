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
      puts "Destroying #{user.uid} rooms - role: #{user.role.name}"
      user.rooms.each do |room|
        if room.sessions.positive? && args[:include_used] != "true"
          puts "Skipping room #{room.uid}"
          next
        end

        begin
          room.destroy(true)
          puts "Destroying room #{room.uid}"
        rescue => e
          puts "Failed to remove room #{room.uid} - #{e}"
        end
      end
    end
  end
end
