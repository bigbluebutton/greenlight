// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

(function() {

  var sessionStatusRefresh = function(url) {
    $.get(url + "/session_status_refresh", function(html) {
      $(".center-panel-wrapper").html(html);
      displayRoomURL();
    });
  }

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'MeetingUpdatesChannel',
      encrypted_id: Meeting.getInstance().getId()
    },
    {
      received: function(data) {
        if (data.action === 'moderator_joined') {
          if (!Meeting.getInstance().getModJoined()) {
            Meeting.getInstance().setModJoined(true);
            if (Meeting.getInstance().getWaitingForMod()) {
              loopJoin();
            } else {
              sessionStatusRefresh($('.meeting-url').val());
              showAlert(I18n.meeting_started, 4000);
            }
          }
        } else if (data.action === 'meeting_ended') {
          sessionStatusRefresh($('.meeting-url').val());
          showAlert(I18n.meeting_ended, 4000);
        }
      }
    });
  };

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
