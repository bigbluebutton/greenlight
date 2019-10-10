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
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  // Only run on the admins page.
  if (controller == "admins" && action == "index") {
    // show the modal with the correct form action url
    $(".delete-user").click(function(){
      $("#delete-confirm").parent().attr("action", $(this).data("path"))

      if ($(this).data("delete") == "temp-delete") {
        $("#perm-delete").hide()
        $("#delete-warning").show()
      } else {
        $("#perm-delete").show()
        $("#delete-warning").hide()
      }
    })
  }

  $(".delete-user").click(function(data){
    document.getElementById("delete-checkbox").checked = false
    $("#delete-confirm").prop("disabled", "disabled")

    if ($(data.target).data("delete") == "temp-delete") {
      $("#perm-delete").hide()
      $("#delete-warning").show()
    } else {
      $("#perm-delete").show()
      $("#delete-warning").hide()
    }
  })

  $("#delete-checkbox").click(function(data){
    if (document.getElementById("delete-checkbox").checked) {
      $("#delete-confirm").removeAttr("disabled")
    } else {
      $("#delete-confirm").prop("disabled", "disabled")
    }
  })
})
