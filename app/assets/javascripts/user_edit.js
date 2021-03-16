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
  if ((controller == "admins" && action == "edit_user") || (controller == "users" && action == "edit")) {
    // Hack to make it play nice with turbolinks
    if ($("#role-dropdown:visible").length == 0){
      $(window).trigger('load.bs.select.data-api')
    }

    // Check to see if the role dropdown was set up
    if ($("#role-dropdown").length != 0){
      $("#role-dropdown").selectpicker('val', $("#user_role_id").val())
    }

    // Update hidden field with new value
    $("#role-dropdown").on("changed.bs.select", function(){
      $("#user_role_id").val($("#role-dropdown").selectpicker('val'))
    })

    // Update hidden field with new value
    // $("#language-dropdown").on("show.bs.select", function(){
    //   $("#language-dropdown").selectpicker('val', $("#user_language").val())
    // })
    
    // Update hidden field with new value
    $("#language-dropdown").on("changed.bs.select", function(){
      $("#user_language").val($("#language-dropdown").selectpicker('val'))
    })
  }
})