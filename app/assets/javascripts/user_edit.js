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
    // Reset the value of the form element that allows the user to clear their avatar
    $("#clear-avatar").val("false")

    //Preview the image in the profile to the new image when a file is uploaded
    $("#user_avatar").change(function() {
      var reader = new FileReader();

      reader.onload = function(e) {
        var file = e.target.result

        // Format of file is 'data:image/*;...'
        let colonLocation = file.indexOf(":") + 1
        var incomingFileType = file.substr(colonLocation, file.indexOf(";")-colonLocation)

        // check to see that the incoming file type is accepted
        if (incomingFileType.startsWith("image/")) {
          $(".invalid-message").hide()

          // If its the first image they upload, remove the letter avatar and preview the image avatar
          if ($("#avatar-letter").length > 0) {
            $("#clear-avatar").val("false")

            document.getElementById("avatar-letter").outerHTML = "<img id='avatar-image' class='avatar avatar-xxl mr-5 mt-2'></img>"
          }

          $("#avatar-image").attr("src", file)
        } else {
          $(".invalid-message").show()
          $("#user_avatar").val("")
        }
      }

      reader.readAsDataURL(this.files[0]);
    })

    // Preview the default avatar if the user clicks the remove image button
    $("#remove-image").click(function() {
      $("#clear-avatar").val("true")
      document.getElementById("avatar-image").outerHTML = "<span id='avatar-letter' class='avatar avatar-xxl mr-5 mt-2 bg-primary'>" + $("#remove-image").data("first") + "</span>"
    })

    // Clear the role when the user clicks the x
    $(".clear-role").click(clearRole)

    // When the user selects an item in the dropdown add the role to the user
    $("#role-select-dropdown").change(function(data){
      var dropdown = $("#role-select-dropdown");
      var select_role_id = dropdown.val();

      if(select_role_id){
        // Disable the role in the dropdown
        var selected_role = dropdown.find('[value=\"' + select_role_id + '\"]');
        selected_role.prop("disabled", true)

        // Add the role tag
        var tag_container = $("#role-tag-container");
        tag_container.append("<span id=\"user-role-tag_" + select_role_id + "\" style=\"background-color:" + selected_role.data("colour") + ";\" class=\"tag user-role-tag\">" + 
          selected_role.text() + "<a data-role-id=\"" + select_role_id + "\" class=\"tag-addon clear-role\"><i data-role-id=\"" + select_role_id + "\" class=\"fas fa-times\"></i></a></span>");

        // Update the role ids input that gets submited on user update
        var role_ids = $("#user_role_ids").val()
        role_ids += " " + select_role_id
        $("#user_role_ids").val(role_ids)
        
        // Add the clear role function to the tag
        $("#user-role-tag_" + select_role_id).click(clearRole);

        // Reset the dropdown
        dropdown.val(null)
      }
    })
  }
})

// This function removes the specfied role from a user
function clearRole(data){
  // Get the role id
  var role_id = $(data.target).data("role-id");
  var role_tag = $("#user-role-tag_" + role_id);

  // Remove the role tag
  $(role_tag).remove()
  
  // Update the role ids input
  var role_ids = $("#user_role_ids").val()
  var parsed_ids = role_ids.split(' ')
  
  var index = parsed_ids.indexOf(role_id.toString());
  
  if (index > -1) {
    parsed_ids.splice(index, 1);
  }
  
  $("#user_role_ids").val(parsed_ids.join(' '))
  
  // Enable the role in the role select dropdown
  var selected_role = $("#role-select-dropdown").find('[value=\"' + role_id + '\"]');
  selected_role.prop("disabled", false)
}