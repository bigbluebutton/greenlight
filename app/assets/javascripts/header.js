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

$(document).on('turbolinks:load', function(){
  // Stores the current url when the user clicks the sign in button
  $(".sign-in-button").click(function(){
    var url = location.href
    // Add the slash at the end if it's missing
    url += url.endsWith("/") ? "" : "/"
    document.cookie ="return_to=" + url
  })

  // Checks to see if the user provided an image url and displays it if they did
  $("#user-image")
    .on("load", function() {
      $("#user-image").show()
      $("#user-avatar").hide()
    })
    .on("error", function() {
      $("#user-image").hide()
      $("#user-avatar").show()
    })
})
