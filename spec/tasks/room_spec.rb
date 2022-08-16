# frozen_string_literal: true

require "rails_helper"

Rails.application.load_tasks

describe "room_remove_expired_rooms" do
  before do
    @user = create(:user)
    @main_room = @user.main_room
    Timecop.freeze(DateTime.parse('2020-12-24 13:45:00'))
  end

  after(:each) do
    Rake::Task["room:remove_expired_rooms"].reenable
  end

  after do
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

    expect(Room.all.map(&:id)).to contain_exactly(@main_room.id, recent_room.id)
  end

  it "should delete expired rooms that were never used so far except of the main room" do
    expired_room = create(:room, owner: @user)
    recent_room = create(:room, owner: @user)
    @main_room.update_attributes(sessions: 0, last_session: nil, updated_at: "2020-12-20 14:15:00")
    expired_room.update_attributes(sessions: 0, last_session: nil, updated_at: "2020-12-20 14:15:00")
    recent_room.update_attributes(sessions: 0, last_session: nil, updated_at: "2020-12-22 07:10:20")

    Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

    expect(Room.all.map(&:id)).to contain_exactly(@main_room.id, recent_room.id)
  end

  it "should not delete rooms that were deleted long ago but were used recently" do
    old_room_recently_used = create(:room, owner: @user)
    old_room_recently_used.update_attributes(sessions: 1, last_session: "2020-12-22 14:15:00",
                                             updated_at: "2019-06-02 20:14:58")

    Rake::Task["room:remove_expired_rooms"].invoke(expiration_time_in_days)

    expect(Room.all.map(&:id)).to contain_exactly(@main_room.id, old_room_recently_used.id)
  end
end
