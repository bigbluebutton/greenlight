# frozen_string_literal: true

require "rails_helper"

describe "rake tasks namespace room" do
  Rails.application.load_tasks

  describe "remove_expired_rooms" do
    before do
      @user = create(:user)
      @main_room = @user.main_room
      Timecop.freeze(DateTime.parse('2020-12-24 13:45:00'))
    end

    after(:each) do
      Rake::Task["room:remove_expired_rooms"].reenable
      Timecop.return
    end

    let(:expiration_time_in_days) { "3" }

    it "should not delete expired main room but all other expired rooms" do
      expired_room = create(:room, owner: @user)
      recent_room = create(:room, owner: @user)
      @main_room.update_attributes(sessions: 1, last_session: "2020-12-20 14:15:00")
      expired_room.update_attributes(sessions: 1, last_session: "2020-12-20 14:15:00")
      recent_room.update_attributes(sessions: 1, last_session: "2020-12-23 16:05:30")

      Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

      expect(Room.pluck(:id)).to contain_exactly(@main_room.id, recent_room.id)
    end

    it "should delete expired rooms that were never used so far except of the main room" do
      expired_room = create(:room, owner: @user)
      recent_room = create(:room, owner: @user)
      @main_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-12-20 14:15:00")
      expired_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-12-20 14:15:00")
      recent_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-12-22 07:10:20")

      Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

      expect(Room.pluck(:id)).to contain_exactly(@main_room.id, recent_room.id)
    end

    it "should not delete rooms that were deleted long ago but were used recently" do
      old_room_recently_used = create(:room, owner: @user)
      old_room_recently_used.update_attributes(sessions: 1, last_session: "2020-12-22 14:15:00",
        created_at: "2019-06-02 20:14:58")

      Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

      expect(Room.pluck(:id)).to contain_exactly(@main_room.id, old_room_recently_used.id)
    end

    it "should not delete expired rooms during the last despite" do
      expired_room = create(:room, owner: @user)
      Timecop.freeze(DateTime.parse('2020-12-24 13:45:00'))
      expired_room.update_attributes(sessions: 1, last_session: "2020-12-06 14:15:00",
        deletion_planned_at: "2020-12-31 14:15:00")

      Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

      expect(Room.pluck(:id)).to contain_exactly(@main_room.id, expired_room.id)
    end

    it "should delete rooms if the last despite is exceeded" do
      expired_room = create(:room, owner: @user)
      Timecop.freeze(DateTime.parse('2020-12-24 13:45:00'))
      expired_room.update_attributes(sessions: 1, last_session: "2020-12-06 14:15:00",
        deletion_planned_at: "2020-12-23 14:15:00")

      Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

      expect(Room.pluck(:id)).to contain_exactly(@main_room.id)
    end
  end

  describe "permanently_remove_deleted_rooms" do
    before do
      @user = create(:user)
      @main_room = @user.main_room
    end

    before(:each) do
      Timecop.freeze(DateTime.parse('2020-12-24 13:45:00'))
    end

    after(:each) do
      Rake::Task["room:permanently_remove_deleted_rooms"].reenable
      Timecop.return
    end

    let(:deleted_time_in_days) { "3" }

    it "should permanently remove rooms that are in deleted state for longer than the specified time" do
      second_room = create(:room, owner: @user)
      @main_room.update_attributes(deleted: true, updated_at: "2020-12-20 14:15:00")
      second_room.update_attributes(deleted: true, updated_at: "2020-12-20 14:15:00")
      expect { Rake::Task["room:permanently_remove_deleted_rooms"].invoke(deleted_time_in_days) }
        .to change { Room.include_deleted.count }.by(-2)
    end

    it "should not permanently remove rooms that are in deleted state for shorter than the specified time" do
      @main_room.update_attributes(deleted: true, updated_at: "2020-12-22 14:15:00")
      expect { Rake::Task["room:permanently_remove_deleted_rooms"].invoke(deleted_time_in_days) }
        .to change { Room.include_deleted.count }.by(0)
    end

    it "should raise an error if no maximum time for the deleted state is specified" do
      expect { Rake::Task["room:permanently_remove_deleted_rooms"].invoke }.to raise_error(ArgumentError)
    end
  end

  describe "notify_of_expiring_rooms" do
    before do
      @user = create(:user)
      @main_room = @user.main_room
      allow(Rails.configuration).to receive(:enable_email_notification).and_return(true)
    end

    before(:each) do
      Timecop.freeze(DateTime.parse('2020-06-01 13:45:00'))
    end

    after(:each) do
      Timecop.return
      Rake::Task["room:notify_of_expiring_rooms"].reenable
      ActionMailer::Base.deliveries.clear
    end

    let(:expiration_time_in_days) { "91" }
    let(:time_in_days_to_potential_expiration_point) { "28" }
    let(:last_despite_in_days) { "28" }
    let(:english_email_notification_template) {
      <<~BODY
        <p>The following rooms will be deleted soon due to disuse if they are not used until the specified date:</p>\
        <ul>\
        <li>%<expired_room_name>s: deletion on %<expired_room_deletion_date_string>s</li>\
        <li>%<second_expired_room_name>s: deletion on %<second_expired_room_deletion_date_string>s</li>\
        </ul>
      BODY
    }
    let(:english_email_notification_template_with_single_room) {
      <<~BODY
        <p>The following rooms will be deleted soon due to disuse if they are not used until the specified date:</p>\
        <ul>\
        <li>%<expired_room_name>s: deletion on %<expired_room_deletion_date_string>s</li>\
        </ul>
      BODY
    }
    # \r at the end is required, see: https://stackoverflow.com/a/52910806
    let(:german_email_notification_template) {
      <<~BODY
        <p>Die folgenden Räume werden in Folge von Nichtgebrauch in Kürze gelöscht, sollten sie bis zum angegebenen Datum nicht erneut benutzt werden:</p>\
        <ul>\
        <li>%<expired_room_name>s: Löschung am %<expired_room_deletion_date_string>s</li>\
        <li>%<second_expired_room_name>s: Löschung am %<second_expired_room_deletion_date_string>s</li>\
        </ul>\r
      BODY
    }

    def invoke_task_with_default_args
      invoke_task(expiration_time_in_days, time_in_days_to_potential_expiration_point, last_despite_in_days, nil)
    end

    def invoke_task(expiration_time_in_days_param, time_in_days_to_potential_expiration_point_param,
      last_despite_in_days_param, locale)
      Rake::Task["room:notify_of_expiring_rooms"].invoke(
        expiration_time_in_days_param, time_in_days_to_potential_expiration_point_param, last_despite_in_days_param, locale
      )
      Rake::Task["room:notify_of_expiring_rooms"].reenable
    end

    def expect_room_property(room, property, expected_value)
      expect(Room.where(id: room.id).pluck(property)[0]).to eq(expected_value)
    end

    it "should set time range to expiration last checked in days property" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")

      invoke_task_with_default_args

      expect_room_property(expired_room,
        :time_range_to_expiration_last_checked_in_days,
        time_in_days_to_potential_expiration_point.to_i)
    end

    it "should not set time range to expiration last checked in days property if room is not going to expire" do
      recent_used_room = create(:room, owner: @user)
      recent_used_room.update_attributes(sessions: 1, last_session: "2020-04-20 13:00:00")

      invoke_task_with_default_args

      expect_room_property(recent_used_room,
        :time_range_to_expiration_last_checked_in_days,
        nil)
    end

    it "should update time range to expiration last checked in days property and notify" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")

      first_time_in_days_to_potential_expiration_point_to_check = 28
      expect {
        invoke_task(expiration_time_in_days, first_time_in_days_to_potential_expiration_point_to_check.to_s,
          last_despite_in_days, nil)
      }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect_room_property(expired_room,
        :time_range_to_expiration_last_checked_in_days,
        first_time_in_days_to_potential_expiration_point_to_check)

      Timecop.freeze(DateTime.parse('2020-06-15 13:45:00'))

      second_time_in_days_to_potential_expiration_point_to_check = 14
      expect {
        invoke_task(expiration_time_in_days, second_time_in_days_to_potential_expiration_point_to_check.to_s,
          last_despite_in_days, nil)
      }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect_room_property(expired_room,
        :time_range_to_expiration_last_checked_in_days,
        second_time_in_days_to_potential_expiration_point_to_check)
    end

    it "should not update expiration last time range checked or notify for increasing time range to check" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")

      first_time_in_days_to_potential_expiration_point_to_check = 28
      expect {
        invoke_task(expiration_time_in_days, first_time_in_days_to_potential_expiration_point_to_check.to_s,
          last_despite_in_days, nil)
      }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect_room_property(expired_room,
        :time_range_to_expiration_last_checked_in_days,
        first_time_in_days_to_potential_expiration_point_to_check)

      second_time_in_days_to_potential_expiration_point_to_check = 30
      expect {
        invoke_task(expiration_time_in_days, second_time_in_days_to_potential_expiration_point_to_check.to_s,
          last_despite_in_days, nil)
      }
        .to change { ActionMailer::Base.deliveries.count }.by(0)
      expect_room_property(expired_room,
        :time_range_to_expiration_last_checked_in_days,
        first_time_in_days_to_potential_expiration_point_to_check)
    end

    it "should not notify of potentially expiring main rooms but all other potentially expiring rooms" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")
      recent_used_room = create(:room, owner: @user)
      recent_used_room.update_attributes(sessions: 1, last_session: "2020-04-20 13:00:00")

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should notify a user of multiple potentially expiring rooms in one mail" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")
      second_expired_room = create(:room, owner: @user)
      second_expired_room.update_attributes(sessions: 1, last_session: "2020-03-10 13:00:00")

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should notify of potentially expiring rooms only once" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: "2020-03-15 14:15:00")

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "should grant a last despite for rooms that are actually already expired during the notification" do
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: '2010-03-15 14:15:00')
      Timecop.freeze(DateTime.parse('2020-06-01 13:45:00'))

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect_room_property(expired_room, :deletion_planned_at, "2020-06-29 13:45:00")
      expect_room_property(expired_room, :time_range_to_expiration_last_checked_in_days,
        last_despite_in_days.to_i)
    end

    it "should not grant a last despite if the user was already notified of the considered room" do
      expired_room = create(:room, owner: @user)
      expired_room.update_attributes(sessions: 1, last_session: '2010-03-15 14:15:00',
        time_range_to_expiration_last_checked_in_days: 35)
      Timecop.freeze(DateTime.parse('2020-06-01 13:45:00'))

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect_room_property(expired_room, :deletion_planned_at, nil)
      expect_room_property(expired_room, :time_range_to_expiration_last_checked_in_days,
        time_in_days_to_potential_expiration_point.to_i)
    end

    it "should notify of rooms that are going to expire because they were never used and updated long ago" do
      expired_room = create(:room, owner: @user)
      recent_room = create(:room, owner: @user)
      @main_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-03-18 14:15:00")
      expired_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-03-15 14:15:00")
      recent_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-04-20 07:10:20")

      expect { invoke_task_with_default_args }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should notify of rooms that are going to expire soon which are owned by that user" do
      @user.update_attributes(email: "snape@hmail.en")
      second_user = create(:user)
      second_user.update_attributes(email: "lupin@hmail.en")
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(name: expired_room_name, sessions: 1, last_session: "2020-03-15 14:15:00")
      second_expired_room = create(:room, owner: second_user)
      second_expired_room_name = 'Defence against the Dark Arts'
      second_expired_room.update_attributes(name: second_expired_room_name,
        sessions: 1, last_session: "2020-03-10 13:00:00")

      invoke_task_with_default_args

      expect(ActionMailer::Base.deliveries.count).to eq(2)

      user_to_expected_email_body = {
        @user.email => format(english_email_notification_template_with_single_room,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: 'June 14, 2020'),
        second_user.email => format(english_email_notification_template_with_single_room,
          expired_room_name: second_expired_room_name,
          expired_room_deletion_date_string: 'June 09, 2020')
      }
      (0..1).each do |i|
        expect(ActionMailer::Base.deliveries[i].body.to_s).to eq(
          user_to_expected_email_body[ActionMailer::Base.deliveries[i].header[:To].to_s]
        )
      end
    end

    it "should sent a notification email with the correct body" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(name: expired_room_name, sessions: 1, last_session: "2020-03-15 14:15:00")
      second_expired_room = create(:room, owner: @user)
      second_expired_room_name = 'Defence against the Dark Arts'
      second_expired_room.update_attributes(name: second_expired_room_name,
        sessions: 1, last_session: "2020-03-10 13:00:00")

      invoke_task_with_default_args

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries[0].body.to_s).to eq(
        format(english_email_notification_template,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: 'June 14, 2020',
          second_expired_room_name: second_expired_room_name,
          second_expired_room_deletion_date_string: 'June 09, 2020')
      )
    end

    it "should sent a notification email with the correct body for rooms that were never used and created long ago" do
      @main_room.update_attributes(sessions: 0, last_session: nil, created_at: "2020-03-18 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(
        name: expired_room_name, sessions: 0, last_session: nil, created_at: "2020-03-15 14:15:00"
      )
      second_expired_room = create(:room, owner: @user)
      second_expired_room_name = 'Defence against the Dark Arts'
      second_expired_room.update_attributes(
        name: second_expired_room_name, sessions: 0, last_session: nil, created_at: "2020-03-10 13:00:00"
      )

      invoke_task_with_default_args

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries[0].body.to_s).to eq(
        format(english_email_notification_template,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: 'June 14, 2020',
          second_expired_room_name: second_expired_room_name,
          second_expired_room_deletion_date_string: 'June 09, 2020')
      )
    end

    it "should adjust the body of the email corresponding to the specified locale" do
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(name: expired_room_name, sessions: 1, last_session: "2020-03-15 14:15:00")
      second_expired_room = create(:room, owner: @user)
      second_expired_room_name = 'Defence against the Dark Arts'
      second_expired_room.update_attributes(name: second_expired_room_name,
        sessions: 1, last_session: "2020-03-10 13:00:00")

      invoke_task(expiration_time_in_days, time_in_days_to_potential_expiration_point, last_despite_in_days, :de_DE)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries[0].body.to_s).to eq(
        format(german_email_notification_template,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: '14. Juni 2020',
          second_expired_room_name: second_expired_room_name,
          second_expired_room_deletion_date_string: '09. Juni 2020')
      )
    end

    it "should prioritize the user defined locale over the specified locale" do
      @user.update_attributes(language: "de_DE")
      @main_room.update_attributes(sessions: 1, last_session: "2020-05-01 14:15:00")
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(name: expired_room_name, sessions: 1, last_session: "2020-03-15 14:15:00")
      second_expired_room = create(:room, owner: @user)
      second_expired_room_name = 'Defence against the Dark Arts'
      second_expired_room.update_attributes(name: second_expired_room_name,
        sessions: 1, last_session: "2020-03-10 13:00:00")

      invoke_task(expiration_time_in_days, time_in_days_to_potential_expiration_point, last_despite_in_days, :en)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries[0].body.to_s).to eq(
        format(german_email_notification_template,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: '14. Juni 2020',
          second_expired_room_name: second_expired_room_name,
          second_expired_room_deletion_date_string: '09. Juni 2020')
      )
    end

    it "should consider deletion planned at date in email body correctly" do
      expired_room = create(:room, owner: @user)
      expired_room_name = 'Potions'
      expired_room.update_attributes(name: expired_room_name, sessions: 1, last_session: '2010-03-15 14:15:00')
      Timecop.freeze(DateTime.parse('2020-06-01 13:45:00'))

      invoke_task(expiration_time_in_days, "3", "28", nil)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries[0].body.to_s).to eq(
        format(english_email_notification_template_with_single_room,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: 'June 29, 2020')
      )

      invoke_task(expiration_time_in_days, "3", "28", nil)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
      expect(ActionMailer::Base.deliveries[1].body.to_s).to eq(
        format(english_email_notification_template_with_single_room,
          expired_room_name: expired_room_name,
          expired_room_deletion_date_string: 'June 29, 2020')
      )
    end

    it "should raise an error if an unsupported locale is specified" do
      expect {
        invoke_task(expiration_time_in_days, time_in_days_to_potential_expiration_point, last_despite_in_days, :sjn)
      }.to raise_error(ArgumentError)
    end
  end
end
