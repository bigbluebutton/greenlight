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
      var url = $("body").data("relative-root")
      if (!url.endsWith("/")) {
        url += "/"
      }
      url += "u/" + uid
      $("#delete-confirm").parent().attr("action", url)
    })

    $('.colorinput').ColorPicker({
      onHide: function (colpkr) {
        var colour = $("#user-colour").val();

        // Update the color in the database and reload the page
        $.post($("#coloring-path").val(), {color: colour}).done(function(data) {
          location.reload()
        });
      },

      onSubmit: function(hsb, hex, rgb, el) {
        $.post($("#coloring-path").val(), {color: '#' + hex}).done(function(data) {
          location.reload()
        });
      },
      
      onBeforeShow: function () {
        var colour = $("#user-colour").val();

        $(this).ColorPickerSetColor(colour);
      },

      onChange: function (hsb, hex, rgb) {
        $('.colorinput span').css('backgroundColor', '#' + hex);
        $("#user-colour").val('#' + hex);
      }
    });
  }

  // Only run on the admins edit user page.
  if (controller == "admins" && action == "edit_user") {
    $(".setting-btn").click(function(data){
      var url = $("body").data("relative-root")
      if (!url.endsWith("/")) {
        url += "/"
      }
      url += "admins?setting=" + data.target.id

      window.location.href = url
    })
  }
});

// Change the branding image to the image provided
function changeBrandingImage(path) {
  var url = $("#branding-url").val()
  $.post(path, {url: url})
}
