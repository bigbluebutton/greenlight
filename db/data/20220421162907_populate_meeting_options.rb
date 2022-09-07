# frozen_string_literal: true

class PopulateMeetingOptions < ActiveRecord::Migration[7.0]
  def up
    MeetingOption.create! [
      # To configure greenlight meetings add new MeetingOption record with the fallowing format
      # { name: #param_name, default_value: #value }
      # where #param_name and #value are respectively the parameter name and value from BBB create API documentation.
      # For a full list check https://docs.bigbluebutton.org/dev/api.html#create:
      #
      # BBB parameters:
      { name: 'record', default_value: 'false' }, # true | false
      { name: 'muteOnStart', default_value: 'false' }, # true | false
      { name: 'guestPolicy', default_value: 'ALWAYS_ACCEPT' }, # ALWAYS_ACCEPT | ALWAYS_DENY | ASK_MODERATOR
      # GL only options:
      { name: 'glAnyoneCanStart', default_value: 'false' }, # true | false
      { name: 'glAnyoneJoinAsModerator', default_value: 'false' }, # true | false
      { name: 'glRequireAuthentication', default_value: 'false' }, # true | false
      { name: 'glModeratorAccessCode', default_value: '' },
      { name: 'glViewerAccessCode', default_value: '' }
    ]
  end

  def down
    MeetingOption.destroy_all
  end
end
