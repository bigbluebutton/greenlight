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
    $(".delete-user").click(function(data){
      var uid = $(data.target).closest("tr").data("user-uid")
      $("#delete-confirm").parent().attr("action", "/u/" + uid)
    })

    // Enable the search bar
    var search_input = $('#search-bar');

    search_input.bind("keyup", function(){

      // Retrieve the current search query
      var search_query = $("#search-value").val();

      //Search for users and display them based on name match
      var users_found = 0;

      var users = $('#users-table').find('tr');

      users.each(function(){
        if($(this).text().toLowerCase().includes(search_query.toLowerCase())){
          users_found = users_found + 1;
          $(this).show();
        }
        else{
          $(this).hide();
        }
      });

      // Show "No users match your search" if no users found
      if(users_found === 0){
        $('#no_users_found').show();
      }
      else{
        $('#no_users_found').hide();
      }
    });

    // Change the color of the color inputs when the color is changed
    $(".colorinput-input").change(function(data) {
      // Get the color from the input
      var color = $(data.target).val()

      // Update the color in the database and reload the page
      $.post($("#coloring-path").val(), {color: color}).done(function(data) {
        location.reload()
      });
    });

  }

  // Only run on the admins edit user page.
  if (controller == "admins" && action == "edit_user") {
    $("#users").click(function(data){
      var url = $("body").data("relative-root")
      if (!url.endsWith("/")) {
        url += "/"
      }
      url += "admins"

      window.location.href = url
    })
  }
});

// Change the branding image to the image provided
function changeBrandingImage(path) {
  var url = $("#branding-url").val()
  $.post(path, {url: url})
}
