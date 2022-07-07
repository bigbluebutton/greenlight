# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RoomSettingsController < ApiController
        # Function updates the default value based on what is given,
        #  as well as goes and updates the current room settings for the existing rooms
        def update
          value = params[:value]
          # If optional, then don't change values
          return render_data status: :ok if value == 'optional'

          # Updating the default value
          meeting_option = MeetingOption.find_by(name: params[:setting_name])
          meeting_option_id = meeting_option.id
          meeting_option.update(default_value: value)

          # Go through all the meeting options and update their room settings
          RoomMeetingOption.where(meeting_option_id:).each do |option|
            option.update(value:)
          end

          render_data status: :ok
        end
      end
    end
  end
end
