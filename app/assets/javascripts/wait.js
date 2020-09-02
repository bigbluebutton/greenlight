// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

// Handle client request to join when meeting starts.
$(document).on("turbolinks:load", function(){
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  if(controller == "rooms" && action == "join"){
    App.waiting = App.cable.subscriptions.create({
      channel: "WaitingChannel",
      roomuid: $(".background").attr("room"),
      useruid: $(".background").attr("user")
    }, {
      connected: function() {
        console.log("connected");
        setTimeout(startRefreshTimeout, 120000);
      },

      disconnected: function(data) {
        console.log("disconnected");
        console.log(data);
      },

      rejected: function() {
        console.log("rejected");
      },

      received: function(data){
        console.log(data);
        if(data.action == "started"){
          request_to_join_meeting();
        }
      }
    });
  }
});

var join_attempts = 0;

var request_to_join_meeting = function(){
  $.post(window.location.pathname, { join_name: $(".background").attr("join-name") })
}

// Refresh the page after 2 mins and attempt to reconnect to ActionCable 
function startRefreshTimeout() {
  var url = new URL(window.location.href)
  url.searchParams.set("reload","true")
  window.location.href = url.href
}
