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

describe Recorder do
  include Recorder
  include BbbServer

  let(:bbb_server) { BigBlueButton::BigBlueButtonApi.new("http://bbb.example.com/bigbluebutton/api", "secret", "0.8") }

  before do
    @user = create(:user)
    @room = @user.main_room
    allow_any_instance_of(Room).to receive(:owner).and_return(@user)
  end

  it "should properly find meeting recordings" do
    allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_recordings).and_return(
      recordings: [
        {
          name: "Example",
          playback: {
            format:
            {
              type: "presentation"
            }
          }
        }
      ]
    )

    expect(recordings(@room.bbb_id)).to contain_exactly(
      name: "Example",
      playbacks:
      [
        {
          type: "presentation"
        }
      ]
    )
  end

  it "gets all filtered and sorted recordings for the user" do
    allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_recordings).and_return(
      recordings: [
        {
          meetingID: @room.bbb_id,
          name: "Example",
          participants: "3",
          playback: {
            format:
            {
              type: "presentation"
            }
          },
          metadata: {
            "gl-listed": "true",
          }
        },
        {
          meetingID: @room.bbb_id,
          name: "aExamaaa",
          participants: "5",
          playback: {
            format:
            {
              type: "other"
            }
          },
          metadata: {
            "gl-listed": "false",
          }
        },
        {
          meetingID: @room.bbb_id,
          name: "test",
          participants: "1",
          playback: {
            format:
            {
              type: "presentation"
            }
          },
          metadata: {
            "gl-listed": "true",
          }
        },
        {
          meetingID: @room.bbb_id,
          name: "Exam",
          participants: "1",
          playback: {
            format:
            {
              type: "other"
            }
          },
          metadata: {
            "gl-listed": "false",
            name: "z",
          }
        }
      ]
    )

    expect(all_recordings(@user.rooms.pluck(:bbb_id), search: "Exam", column: "name",
      direction: "desc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks:
              [
                {
                  type: "presentation"
                }
              ],
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "5",
            playbacks:
              [
                {
                  type: "other"
                }
              ],
            metadata: {
              "gl-listed": "false",
            }
          }
        ]
      )
  end

  context '#filtering' do
    before do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_recordings).and_return(
        recordings: [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playback: {
              format:
              {
                type: "presentation"
              }
            },
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "5",
            playback: {
              format:
              {
                type: "other"
              }
            },
            metadata: {
              "gl-listed": "false",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "test",
            participants: "1",
            playback: {
              format:
              {
                type: "presentation"
              }
            },
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "Exam",
            participants: "1",
            playback: {
              format:
              {
                type: "other"
              }
            },
            metadata: {
              "gl-listed": "false",
              name: "metadata",
            }
          }
        ]
      )
    end

    it "should filter recordings on name" do
      expect(recordings(@room.bbb_id, search: "Exam")).to contain_exactly(
        {
          meetingID: @room.bbb_id,
          name: "aExamaaa",
          participants: "5",
          playbacks:
            [
              {
                type: "other"
              }
            ],
          metadata: {
            "gl-listed": "false",
          }
        },
          meetingID: @room.bbb_id,
          name: "Example",
          participants: "3",
          playbacks:
            [
              {
                type: "presentation"
              }
            ],
          metadata: {
            "gl-listed": "true",
          }
      )
    end

    it "should filter recordings on participants" do
      expect(recordings(@room.bbb_id, search: "5")).to contain_exactly(
        meetingID: @room.bbb_id,
        name: "aExamaaa",
        participants: "5",
        playbacks:
          [
            {
              type: "other"
            }
          ],
        metadata: {
          "gl-listed": "false",
        }
      )
    end

    it "should filter recordings on format" do
      expect(recordings(@room.bbb_id, search: "presentation")).to contain_exactly(
        {
          meetingID: @room.bbb_id,
          name: "test",
          participants: "1",
          playbacks:
              [
                {
                  type: "presentation"
                }
              ],
          metadata: {
            "gl-listed": "true",
          }
        },
          meetingID: @room.bbb_id,
          name: "Example",
          participants: "3",
          playbacks:
              [
                {
                  type: "presentation"
                }
              ],
          metadata: {
            "gl-listed": "true",
          }
      )
    end

    it "should filter recordings on visibility" do
      expect(recordings(@room.bbb_id, search: "public")).to contain_exactly(
        {
          meetingID: @room.bbb_id,
          name: "test",
          participants: "1",
          playbacks:
              [
                {
                  type: "presentation"
                }
              ],
          metadata: {
            "gl-listed": "true",
          },
        },
          meetingID: @room.bbb_id,
          name: "Example",
          participants: "3",
          playbacks:
              [
                {
                  type: "presentation"
                }
              ],
          metadata: {
            "gl-listed": "true",
          }
      )
    end

    it "should filter recordings on metadata name by default" do
      expect(recordings(@room.bbb_id, search: "metadata")).to contain_exactly(
        meetingID: @room.bbb_id,
        name: "Exam",
        participants: "1",
        playbacks:
            [
              {
                type: "other"
              }
            ],
        metadata: {
          "gl-listed": "false",
          name: "metadata",
        }
      )
    end
  end

  context '#sorting' do
    before do
      allow_any_instance_of(BigBlueButton::BigBlueButtonApi).to receive(:get_recordings).and_return(
        recordings: [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playback: {
              format: {
                type: "presentation",
                length: "4"
              }
            },
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playback: {
              format: {
                type: "other",
                length: "3"
              }
            },
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          }
        ]
      )
    end

    it "should sort recordings on name" do
      expect(recordings(@room.bbb_id, column: "name", direction: "asc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks: [
              {
                type: "presentation",
                length: "4"
              }
            ],
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playbacks: [
              {
                type: "other",
                length: "3"
              }
            ],
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          }
        ]
      )
    end

    it "should sort recordings on participants" do
      expect(recordings(@room.bbb_id, column: "users", direction: "desc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks: [
              {
                type: "presentation",
                length: "4"
              }
            ],
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playbacks: [
              {
                type: "other",
                length: "3"
              }
            ],
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          }
        ]
      )
    end

    it "should sort recordings on visibility" do
      expect(recordings(@room.bbb_id, column: "visibility", direction: "desc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks: [
              {
                type: "presentation",
                length: "4"
              }
            ],
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playbacks: [
              {
                type: "other",
                length: "3"
              }
            ],
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          }
        ]
      )
    end

    it "should sort recordings on length" do
      expect(recordings(@room.bbb_id, column: "length", direction: "asc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playbacks: [
              {
                type: "other",
                length: "3"
              }
            ],
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks: [
              {
                type: "presentation",
                length: "4"
              }
            ],
            metadata: {
              "gl-listed": "true",
            }
          }
        ]
      )
    end

    it "should sort recordings on format" do
      expect(recordings(@room.bbb_id, column: "formats", direction: "desc")).to eq(
        [
          {
            meetingID: @room.bbb_id,
            name: "Example",
            participants: "3",
            playbacks: [
              {
                type: "presentation",
                length: "4"
              }
            ],
            metadata: {
              "gl-listed": "true",
            }
          },
          {
            meetingID: @room.bbb_id,
            name: "aExamaaa",
            participants: "1",
            playbacks: [
              {
                type: "other",
                length: "3"
              }
            ],
            metadata: {
              name: "Z",
              "gl-listed": "false"
            }
          }
        ]
      )
    end
  end
end
