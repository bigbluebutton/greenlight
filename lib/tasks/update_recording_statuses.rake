
namespace :recording do
  task :update_statuses, [] => :environment do |_task, _args|
    RecordingStatus.where(available: false).each do |recording_status|
      status = RecordingChecker.available?(recording_status.record_id)

      recording_status.update(available: status)
    end
  end
end
