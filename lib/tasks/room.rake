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

  task four: :environment do
    Room.all.each do |room|
      next if room.uid.split("-").length > 3

      begin
        new_uid = room.uid + "-" + SecureRandom.alphanumeric(3).downcase
        puts "Updating #{room.uid} to #{new_uid}"
        room.update_attributes(uid: new_uid)
      rescue => e
        puts "Failed to update #{room.uid} to #{new_uid} - #{e}"
      end
    end
  end

  desc "Creates a user room"
  task :create, [:roomname, :email, :room_settings] => :environment do |_task, args|
    u = {
      roomname: args[:roomname],
      email: args[:email],
      room_settings: args[:room_settings]
    }
    user = User.find_by(email: u[:email])
    unless !user.nil?
      puts "User : #{u[:email]} not found"
      exit
    end

    user_id = user.id
    room = Room.create(user_id: user_id, name: u[:roomname], room_settings: u[:room_settings])

    unless room.valid?
      puts "Invalid Arguments"
      puts room.errors.messages
      exit
    end

    puts "Room successfully created."
    puts "Roomname: #{u[:roomname]}"
    puts "User: #{u[:email]}"
    puts "Room Settings: #{u[:room_settings]}"
  end

  desc "Creates a user room and shares it with users"
  task :createAndShare, [:roomname, :email, :users, :room_settings] => :environment do |_task, args|
    u = {
      roomname: args[:roomname],
      email: args[:email],
      users: args[:users],
      room_settings: args[:room_settings]
    }
    user = User.find_by(email: u[:email])
    unless !user.nil?
      puts "User : #{u[:email]} not found"
      exit
    end

    user_id = user.id
    room = Room.create(user_id: user_id, name: u[:roomname], room_settings: u[:room_settings])

    unless room.valid?
      puts "Invalid Arguments"
      puts room.errors.messages
      exit
    end

    puts "Room successfully created."
    puts "Roomname: #{u[:roomname]}"
    puts "User: #{u[:email]}"
    puts "Room Settings: #{u[:room_settings]}"

    ids = u[:users].split ' '
    ids.each { |useremail|
      user = User.find_by(email: useremail)
      user_id = user.id
      SharedAccess.create(room_id: room.id, user_id: user_id)
      puts "Share room #{u[:roomname]} with user #{useremail}."
    }
  end
end
