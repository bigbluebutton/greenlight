# frozen_string_literal: true

namespace :office365 do
  desc "Migrates over old office365 users to new account"
  task :migrate, [] => :environment do |_task, _args|
    old_office_users = User.where(provider: "microsoft_office365")

    old_office_users.each do |old_user|
      new_social_uid = if old_user.email.match("^outlook_[0-9a-zA-Z]+@outlook.com$")
        old_user.email.last(old_user.email.length - 8).split('@')[0]
      else
        old_user.social_uid.split('@')[0]
      end

      new_user = User.where(provider: "office365", social_uid: new_social_uid).first

      if new_user.nil?
        old_user.provider = "office365"
        old_user.social_uid = new_social_uid
        old_user.save!
      else
        old_main_room = old_user.main_room
        old_main_room.name = "Old #{old_main_room.name}"
        old_main_room.save!

        new_user.rooms << old_user.rooms
        new_user.role_ids = new_user.role_ids | old_user.role_ids
        new_user.save!
        old_user.delete
      end
    end
  end
end
