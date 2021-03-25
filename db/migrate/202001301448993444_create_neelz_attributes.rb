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

class CreateNeelzAttributes < ActiveRecord::Migration[5.0]
  def change
    create_table "neelz_attributes", force: :cascade do |t|
      t.integer "neelz_room_id", null: false
      t.integer "qvid", null: false
      t.string "name_of_study", null: false
      t.string "interviewer_name"
      t.string "proband_alias"
      t.boolean "interviewer_browses", default: true
      t.boolean "proband_browses", default: true
      t.string "interviewer_url"
      t.string "proband_url"
      t.boolean "proband_readonly", default: false
      t.boolean "co_browsing_externally_triggered", default: false
      t.integer "interviewer_screen_split_mode_on_login", default: 5
      t.integer "proband_screen_split_mode_on_login", default: 1
      t.integer "proband_screen_split_mode_on_share", default: 5
      t.integer "external_frame_min_width", default: 1024
      t.boolean "show_participants_on_login", default: true
      t.boolean "show_chat_on_login", default: false
      t.boolean "always_record", default: false
      t.boolean "allow_start_stop_record", default: true
      t.datetime "updated_at", null: false
      t.index ["neelz_room_id"], name: "index_neelz_attributes_on_room_id", unique: true
      t.index ["qvid"], name: "index_neelz_attributes_on_qvid", unique: true
    end
  end
end
