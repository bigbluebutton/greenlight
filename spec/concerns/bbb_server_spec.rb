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
require 'logger'

describe BbbServer do
  include BbbServer
  let(:bbb_server) { BigBlueButton::BigBlueButtonApi.new("http://bbb.example.com/bigbluebutton/api", "secret", "0.8") }

  before do
    @user = create(:user)
    @room = @user.main_room
  end

  context "#running?" do
    it "should return false when not running" do
      expect(room_running?(@room.bbb_id)).to be false
    end

    it "should return true when running" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:is_meeting_running?).and_return(true)
      expect(room_running?(@room.bbb_id)).to be true
    end
  end

  context "starting and joining a room session" do
    let(:logger) { Logger.new($stdout) }
    define_method(:timestamp_to_datetime) { |timestamp| DateTime.strptime(timestamp.to_s, "%Q") }
    define_method(:from_ms_to_s) { |timestamp| timestamp.to_i / 1000 }
    context "#start_session" do
      context "inconssisstent createTime with the BBB server" do
        context "newly created room" do
          it "should update the room info on the first create request" do
            allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
              createTime: "1611793449622"
            )
            expect(@room.last_session).to be nil
            expect { start_session(@room) }.to change { @room.sessions }.from(0).to(1)
            expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
          end
          it "should update the room info on duplicated create requests" do
            allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
              messageKey: "duplicateWarning",
              createTime: "1611793449622"
            )
            expect(@room.last_session).to be nil
            expect { start_session(@room) }.to change { @room.sessions }.from(0).to(1)
            expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
          end
        end

        context "previously used room" do
          it "should update the room info on the first create request" do
            allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
              createTime: "1611793449622"
            )
            expect(@room.sessions).to be_zero
            @room.update_attributes(sessions: 1, last_session: timestamp_to_datetime("1011793109622"))
            expect(@room.last_session).to be_present
            expect { start_session(@room) }.to change { @room.sessions }.from(1).to(2)
            expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
          end
          it "should update the room info on duplicated create requests" do
            allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
              messageKey: "duplicateWarning",
              createTime: "1611793449622"
            )
            expect(@room.sessions).to be_zero
            @room.update_attributes(sessions: 1, last_session: timestamp_to_datetime("1011793109622"))
            expect(@room.last_session).to be_present
            expect { start_session(@room) }.to change { @room.sessions }.from(1).to(2)
            expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
          end
        end
      end
      context "conssisstent createTime with the BBB server" do
        it "should not update the session info" do
          allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
            messageKey: "duplicateWarning",
            createTime: "1611793449622"
          )
          @room.update_attributes(sessions: 1, last_session: timestamp_to_datetime("1611793449622"))
          expect(@room.sessions).to eq(1)
          expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
          expect { start_session(@room) }.not_to change { @room.sessions }
          expect(@room.last_session.to_time.to_i).to eq(from_ms_to_s(bbb_server.create_meeting("", "", "")[:createTime]))
        end
      end
    end

    context "#join_path" do
      it "should return correct join URL for user" do
        allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_meeting_info).and_return(
          attendeePW: @room.attendee_pw,
        )
        allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:create_meeting).and_return(
          messageKey: "",
          createTime: "1611793449622"
        )

        endpoint = Rails.configuration.bigbluebutton_endpoint
        secret = Rails.configuration.bigbluebutton_secret
        fullname = "&fullName=Example"
        join_via_html5 = "&join_via_html5=true"
        meeting_id = "&meetingID=#{@room.bbb_id}"
        password = "&password=#{@room.attendee_pw}"
        time = "createTime=1611793449622"

        query = time + fullname + join_via_html5 + meeting_id + password
        checksum_string = "join#{query + secret}"

        checksum = OpenSSL::Digest.digest('sha1', checksum_string).unpack1("H*")
        expect(join_path(@room, "Example")).to eql("#{endpoint}join?#{query}&checksum=#{checksum}")
      end
    end
  end

  context "#recordings" do
    it "publishes a recording" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:publish_recordings).and_return(
        returncode: true, published: true
      )

      expect(publish_recording(Faker::IDNumber.valid))
        .to contain_exactly([:returncode, true], [:published, true])
    end

    it "unpublishes a recording" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:publish_recordings).and_return(
        returncode: true, published: false
      )

      expect(unpublish_recording(Faker::IDNumber.valid))
        .to contain_exactly([:returncode, true], [:published, false])
    end

    it "deletes the recording" do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:delete_recordings).and_return(
        returncode: true, deleted: true
      )

      expect(delete_recording(Faker::IDNumber.valid))
        .to contain_exactly([:returncode, true], [:deleted, true])
    end
  end
end
