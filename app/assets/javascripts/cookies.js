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
  $("#cookies-agree-button").click(function() {
    //create a cookie that lasts 1 year
    var cookieDate = new Date();
    cookieDate.setFullYear(cookieDate.getFullYear() + 1); //1 year from now
    document.cookie = "cookie_consented=true; path=/; expires=" + cookieDate.toUTCString() + ";"

    //hide the banner at the bottom
    $(".cookies-banner").attr("style","display:none !important")
  })

  $("#maintenance-close").click(function(event) {
    //create a cookie that lasts 1 day

    var cookieDate = new Date()
    cookieDate.setDate(cookieDate.getDate() + 1) //1 day from now
    console.log("maintenance_window=" + $(event.target).data("date") + "; path=/; expires=" + cookieDate.toUTCString() + ";")

    document.cookie = "maintenance_window=" + $(event.target).data("date") + "; path=/; expires=" + cookieDate.toUTCString() + ";"
  })
})
