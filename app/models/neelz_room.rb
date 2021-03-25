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

class NeelzRoom < Room

  has_one :neelz_attributes

  def init_new(name_of_study, qvid)
    self.neelz_attributes = NeelzAttributes.new
    self.neelz_attributes.room = self
    self.access_code = rand(10000...99999).to_s
    self.room_settings = create_room_settings_string
    set_qvid(qvid)
    set_name_of_study(name_of_study)
    set_updated_at(DateTime.now)
  end

  def save
    super
    self.neelz_attributes.save
  end

  #ActionCable methods:

  def notify_co_browsing_share
    ActionCable.server.broadcast("#{self.uid}_co_browsing_channel",
                                 {action: "share", url: "#{proband_url}",
                                  readonly: "#{proband_readonly? ? '1' : '0'}"})
  end

  def notify_co_browsing_unshare
    ActionCable.server.broadcast("#{self.uid}_co_browsing_channel", {action: "unshare"})
  end

  def notify_co_browsing_refresh
    ActionCable.server.broadcast("#{self.uid}_co_browsing_channel", {action: "refresh"})
  end

  def notify_co_browsing_thank_you
    ActionCable.server.broadcast("#{self.uid}_co_browsing_channel", {action: "thank_you"})
  end

  #Property accessors

  def name_of_study
    neelz_attributes.name_of_study
  end

  def set_name_of_study(name)
    neelz_attributes.name_of_study = name
    self.name = name + ' - Interview #' + qvid_proband_encoded
  end

  def qvid
    neelz_attributes.qvid
  end

  def set_qvid(qvid_nr)
    neelz_attributes.qvid = qvid_nr
    set_uid('kon-survey-' + qvid_interviewer_encoded)
  end

  def qvid_interviewer_encoded
    val = (qvid + 93) * 2 + 11
    val.to_s(36)
  end

  def qvid_proband_encoded
    val = (qvid + 117) * 3 + 213
    'k' + val.to_s(24)
  end

  def self.decode_proband_qvid(proband_qvid)
    p_qvid = proband_qvid[1..-1].to_i(24)
    ((p_qvid - 213) / 3) - 117
  end

  def set_updated_at(date_now)
    neelz_attributes.updated_at = date_now
  end

  def proband_url
    neelz_attributes.proband_url
  end

  def proband_readonly?
    neelz_attributes.proband_readonly
  end

  def set_proband_url(url)
    neelz_attributes.proband_url = url
  end

  def set_proband_readonly(readonly)
    neelz_attributes.proband_readonly = readonly
  end

  def interviewer_url
    neelz_attributes.interviewer_url
  end

  def set_interviewer_url(url)
    neelz_attributes.interviewer_url = url
  end

  def interviewer_browses?
    neelz_attributes.interviewer_browses;
  end

  def proband_browses?
    neelz_attributes.proband_browses
  end

  def set_interviewer_browses(i_browses)
    neelz_attributes.interviewer_browses = i_browses
  end

  def set_proband_browses(c_browses)
    neelz_attributes.proband_browses = c_browses
  end

  def proband_alias
    neelz_attributes.proband_alias
  end

  def set_proband_alias(name)
    neelz_attributes.proband_alias = name
  end

  def co_browsing_externally_triggered?
    neelz_attributes.co_browsing_externally_triggered
  end

  def set_co_browsing_externally_triggered(ext_triggered)
    neelz_attributes.co_browsing_externally_triggered = ext_triggered
  end

  def interviewer_name
    neelz_attributes.interviewer_name
  end

  def set_interviewer_name(name)
    neelz_attributes.interviewer_name = name
  end

  def interviewer_screen_split_mode_on_login
    neelz_attributes.interviewer_screen_split_mode_on_login
  end

  def set_interviewer_screen_split_mode_on_login(mode)
    neelz_attributes.interviewer_screen_split_mode_on_login = mode
  end

  def proband_screen_split_mode_on_login
    neelz_attributes.proband_screen_split_mode_on_login
  end

  def set_proband_screen_split_mode_on_login(mode)
    neelz_attributes.proband_screen_split_mode_on_login = mode
  end

  def proband_screen_split_mode_on_share
    neelz_attributes.proband_screen_split_mode_on_share
  end

  def set_proband_screen_split_mode_on_share(mode)
    neelz_attributes.proband_screen_split_mode_on_share = mode
  end

  def external_frame_min_width
    neelz_attributes.external_frame_min_width
  end

  def set_external_frame_min_width(min_width)
    neelz_attributes.external_frame_min_width = min_width
  end

  def show_participants_on_login?
    neelz_attributes.show_participants_on_login
  end

  def set_show_participants_on_login(show_participants)
    neelz_attributes.show_participants_on_login = show_participants
  end

  def show_chat_on_login?
    neelz_attributes.show_chat_on_login
  end

  def set_show_chat_on_login(show_participants)
    neelz_attributes.show_chat_on_login = show_participants
  end

  def always_record?
    neelz_attributes.always_record
  end

  def set_always_record(always_record)
    neelz_attributes.always_record = always_record
  end

  def allow_start_stop_record?
    neelz_attributes.allow_start_stop_record
  end

  def set_allow_start_stop_record(allow_start_stop)
    neelz_attributes.allow_start_stop_record = allow_start_stop
  end

  def proband_access_url
    Rails.configuration.instance_url + 'neelz/cgate/' + qvid_proband_encoded
  end

  def self.get_room(qvid:, name_of_study: '')
    #find function user
    neelz_user = User.include_deleted.find_by(email: Rails.configuration.neelz_email)
    if neelz_user
      neelz_attr = NeelzAttributes.find_by(qvid: qvid)
      if neelz_attr
        neelz_room = NeelzRoom.find_by(id: neelz_attr.neelz_room_id)
      else
        neelz_room = self.create_room(neelz_user, name_of_study, qvid)
      end
      neelz_room
    end
  end

  def self.is_neelz_room?(room)
    !!NeelzAttributes.find_by(neelz_room_id: room.id)
  end

  def self.convert_to_neelz_room(room)
    neelz_attr = NeelzAttributes.find_by(neelz_room_id: room.id)
    if neelz_attr
      NeelzRoom.find_by(id: neelz_attr.neelz_room_id)
    end
  end

  private

  def self.create_room(owner, name_of_study, qvid)
    room = NeelzRoom.new(name: 'tmp_name')
    room.owner = owner
    room.setup
    room.init_new(name_of_study, qvid)
    room.save
    room
  end

  def create_room_settings_string
    room_settings = {
      "muteOnStart": false,
      "requireMderatorApproval": false,
      "anyoneCanStart": false,
      "joinModerator": false
    }
    room_settings.to_json
  end

end
