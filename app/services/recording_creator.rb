# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class RecordingCreator
  def initialize(recording:, first_creation: false)
    @recording = recording
    @first_creation = first_creation
  end

  def call
    meeting_id = @recording[:metadata][:meetingId] || @recording[:meetingID]
    room = Room.find_by(meeting_id:)
    raise ActiveRecord::RecordNotFound if room.nil?

    @provider = room.user.provider

    # If the recording is being created for the first time, get the visibility from the site setting
    visibility = if @first_creation
                   default_recording_visibility
                 else
                   recording_visibility
                 end

    # Get length of presentation format(s)
    length = recording_length

    new_name = @recording[:metadata][:name] || @recording[:name]

    new_recording = Recording.find_or_initialize_by(record_id: @recording[:recordID])
    new_recording.room_id = room.id
    new_recording.name = new_name
    new_recording.visibility = visibility
    new_recording.participants = @recording[:participants]
    new_recording.length = length
    new_recording.protectable = @recording[:protected].present?
    new_recording.recorded_at = @recording[:startTime]
    new_recording.save!

    # Create format(s)
    create_formats(new_recording:)

    return unless @first_creation

    BigBlueButtonApi.new(provider: @provider).update_recording_visibility(record_id: new_recording.record_id, visibility:)
  end

  private

  # Returns the default recording visibility for a recording that is being created for the first time
  def default_recording_visibility
    SettingGetter.new(setting_name: 'DefaultRecordingVisibility', provider: @provider).call || 'Published'
  end

  # Returns the visibility of the recording (published, unpublished or protected)
  def recording_visibility
    list = @recording[:metadata][:'gl-listed'].to_s == 'true'
    protect = @recording[:protected].to_s == 'true'
    publish = @recording[:published].to_s == 'true'

    visibility = visibility_for(publish:, protect:, list:)

    return visibility unless visibility.nil?

    Recording::VISIBILITIES[:unpublished]
  end

  # Returns the length of presentation recording for the recording given
  def recording_length
    length = 0
    if @recording[:playback][:format].is_a?(Array)
      @recording[:playback][:format].each do |formats|
        length = formats[:length] if formats[:type] == 'presentation' || formats[:type] == 'video'
      end
    else
      length = @recording[:playback][:format][:length]
    end
    length
  end

  # Creates format(s) for given new_recording
  def create_formats(new_recording:)
    if @recording[:playback][:format].is_a?(Array)
      @recording[:playback][:format].each do |format|
        Format.find_or_create_by(recording_id: new_recording.id, recording_type: format[:type]).update(url: format[:url])
      end
    else
      Format.find_or_create_by(recording_id: new_recording.id,
                               recording_type: @recording[:playback][:format][:type]).update(url: @recording[:playback][:format][:url])
    end
  end

  # Visibilitiy Map
  def visibility_for(publish:, protect:, list:)
    params_for = {
      { publish: false, protect: false, list: false } => Recording::VISIBILITIES[:unpublished],
      { publish: true, protect: false, list: false } => Recording::VISIBILITIES[:published],
      { publish: true, protect: false, list: true } => Recording::VISIBILITIES[:public],
      { publish: true, protect: true, list: false } => Recording::VISIBILITIES[:protected],
      { publish: true, protect: true, list: true } => Recording::VISIBILITIES[:public_protected]
    }

    params_for[{ publish:, protect:, list: }]
  end
end
