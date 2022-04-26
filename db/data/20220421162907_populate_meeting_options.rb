# frozen_string_literal: true

class PopulateMeetingOptions < ActiveRecord::Migration[7.0]
  def up
    MeetingOption.create! [
      # To configure greenlight meetings add new MeetingOption record with the fallowing format
      # { name: #param_name, default_value: #value }
      # where #param_name and #value are respectively the paramter name and value from BBB create API documentation.
      # For a full list check https://docs.bigbluebutton.org/dev/api.html#create:
      #
      # BBB paramters:
      { name: 'record', default_value: 'false' }, # true | false
      { name: 'muteOnStart', default_value: 'false' }, # true | false
      { name: 'guestPolicy', default_value: 'ALWAYS_ACCEPT' }, # ALWAYS_ACCEPT | ALWAYS_DENY | ASK_MODERATOR
      { name: 'logoutURL', default_value: '' },
      { name: 'logo', default_value: 'https://blindsidenetworks.com/wp-content/uploads/2021/04/cropped-bn_logo-02.png' },
      { name: 'attendeePW', default_value: '' },
      { name: 'moderatorPW', default_value: '' },
      # Meta parameters:
      { name: 'meta_gl-v3-listed', default_value: 'public' },
      { name: 'meta_bbb-origin-version', default_value: 3 },
      { name: 'meta_bbb-origin', default_value: 'Greenlight' },
      # GL only options:
      { name: 'glAnyoneCanStart', default_value: 'false' }, # true | false
      { name: 'glAnyoneJoinAsModerator', default_value: 'false' }, # true | false
      { name: 'glModeratorAccessCode', default_value: '' },
      { name: 'glAttendeeAccessCode', default_value: '' }
    ]
  end

  def down
    MeetingOption.destroy_all
  end
end
