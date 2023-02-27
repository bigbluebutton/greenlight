# frozen_string_literal: true

desc 'Sync recordings with BBB server'

task sync_recordings: :environment do
  Recording.destroy_all

  Room.select(:id, :meeting_id).in_batches(of: 25) do |rooms|
    meeting_ids = rooms.pluck(:meeting_id)

    recordings = BigBlueButtonApi.new.get_recordings(meeting_ids:)
    recordings[:recordings].each do |recording|
      RecordingCreator.new(recording:).call
    end
  end
end
