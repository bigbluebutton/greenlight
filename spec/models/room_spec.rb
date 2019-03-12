# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require "rails_helper"
require 'bigbluebutton_api'

describe Room, type: :model do
  before do
    @user = create(:user)
    @room = @user.main_room
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
  end

  context 'associations' do
    it { should belong_to(:owner).class_name("User").with_foreign_key("user_id") }
  end

  context '#setup' do
    it 'creates random uid and bbb_id' do
      expect(@room.uid).to_not be_nil
      expect(@room.bbb_id).to_not be_nil
    end
  end

  context "#to_param" do
    it "uses uid as the default identifier for routes" do
      expect(@room.to_param).to eq(@room.uid)
    end
  end

  context "#invite_path" do
    it "should have correct invite path" do
      expect(@room.invite_path).to eq("/#{@room.uid}")
    end
  end

  context "#owned_by?" do
    it "should return true for correct owner" do
      expect(@room.owned_by?(@user)).to be true
    end

    it "should return false for incorrect owner" do
      expect(@room.owned_by?(create(:user))).to be false
    end
  end

  context "#running?" do
    it "should return false when not running" do
      expect(@room.running?).to be false
    end

    it "should return true when running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(true)
      expect(@room.running?).to be true
    end
  end

  context "#start_session" do
    it "should update latest session info" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
        messageKey: ""
      )

      expect do
        @room.start_session
      end.to change { @room.sessions }.by(1)

      expect(@room.last_session.utc.to_i).to eq(Time.now.to_i)
    end
  end

  context "#join_path" do
    it "should return correct join URL for user" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_meeting_info).and_return(
        attendeePW: "testpass"
      )

      if Rails.configuration.loadbalanced_configuration
        endpoint = Rails.configuration.loadbalancer_endpoint
        secret = Rails.configuration.loadbalancer_secret
      else
        endpoint = Rails.configuration.bigbluebutton_endpoint
        secret = Rails.configuration.bigbluebutton_secret
      end
      fullname = "fullName=Example"
      meeting_id = "&meetingID=#{@room.bbb_id}"
      password = "&password=testpass"

      query = fullname + meeting_id + password
      checksum_string = "join#{query + secret}"

      checksum = OpenSSL::Digest.digest('sha1', checksum_string).unpack("H*").first
      expect(@room.join_path("Example")).to eql("#{endpoint}join?#{query}&checksum=#{checksum}")
    end
  end

  context "#notify_waiting" do
    it "should broadcast to waiting channel with started action" do
      expect do
        @room.notify_waiting
      end.to have_broadcasted_to("#{@room.uid}_waiting_channel").with(a_hash_including(action: "started"))
    end
  end

  context "#participants" do
    it "should link participants to accounts" do
      user1 = create(:user)
      user2 = create(:user)

      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_meeting_info).and_return(
        attendees: [
          { userID: user1.uid, fullName: user1.name },
          { userID: "non-matching-uid", fullName: "Guest User" },
          { userID: user2.uid, fullName: user2.name },
        ],
      )

      expect(@room.participants).to contain_exactly(user1, nil, user2)
    end
  end

  context "#recordings" do
    it "should properly find meeting recordings" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_recordings).and_return(
        recordings: [
          {
            name: "Example",
            playback: {
              format: "presentation",
            },
          },
        ],
      )

      expect(@room.recordings).to contain_exactly(
        name: "Example",
        playbacks: %w(presentation),
      )
    end

    it "deletes the recording" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:delete_recordings).and_return(
        returncode: true, deleted: true
      )

      expect(@room.delete_recording(Faker::IDNumber.valid))
        .to contain_exactly([:returncode, true], [:deleted, true])
    end
  end
end
