# frozen_string_literal: true

require "bbb_api.rb"

namespace :room do
  desc "Generates new bbb_ids for rooms with duplicate bbb_ids"
  task :duplicate, [:provider] => :environment do |_task, args|
    include BbbApi

    @bbb_server = args[:provider].present? ? bbb(args[:provider]) : bbb("greenlight")
    ids = Room.select(:bbb_id).group(:bbb_id).having("count(*) > 1").pluck(:bbb_id)

    ids.each do |id|
      rooms = if args[:provider].present?
        Room.includes(:owner).where(bbb_id: id, users: { provider: args[:provider] })
      else
        Room.where(bbb_id: id)
      end

      rooms.each do |room|
        old_bbb_id = room.bbb_id

        if recordings?(old_bbb_id)
          puts "Skipping #{old_bbb_id} because it has recordings"
          break
        end

        puts "Generating new id for #{room.name}"
        new_bbb_id = unique_bbb_id

        begin
          room.update_attribute(:bbb_id, new_bbb_id)
          puts "Updated #{old_bbb_id} to #{new_bbb_id}"
        rescue => e
          puts "Failed to updated bbb_id for #{old_bbb_id} - #{e}"
        end
      end
    end
  end

  def recordings?(meeting_id)
    !@bbb_server.get_recordings(meetingID: meeting_id)[:recordings].empty?
  end

  # Generates a unique bbb_id based on uuid.
  def unique_bbb_id
    loop do
      bbb_id = SecureRandom.hex(20)
      break bbb_id unless Room.exists?(bbb_id: bbb_id)
    end
  end
end
