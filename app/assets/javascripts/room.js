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

// Room specific js for copy button and email link.
$(document).on('turbolinks:load', function(){
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  // Only run on room pages.
  if (controller == "rooms" && action == "show"){
    var copy = $('#copy');

    // Handle copy button.
    copy.on('click', function(){
      var inviteURL = $('#invite-url');
      inviteURL.select();

      var success = document.execCommand("copy");
      if (success) {
        inviteURL.blur();
        copy.addClass('btn-success');
        copy.html("<i class='fas fa-check'></i>" + getLocalizedString("copied"))
        setTimeout(function(){
          copy.removeClass('btn-success');
          copy.html("<i class='fas fa-copy'></i>" + getLocalizedString("copy"))
        }, 2000)
      }
    });

    // Forces the wrapper to take the entire screen height if the user can't create rooms
    if ($("#cant-create-room-wrapper").length){
      $(".wrapper").css('height', '100%').css('height', '-=130px');
    }

    // Display and update all fields related to creating a room in the createRoomModal
    $("#create-room-block").click(function(){
      showCreateRoom(this)
    })

    // Display and update all fields related to creating a room in the createRoomModal
    $(".update-room").click(function(){
      showUpdateRoom(this)
    })

    $(".delete-room").click(function() {
      showDeleteRoom(this)
    })
  }
});

function showCreateRoom(target) {
  var modal = $(target)
  $("#create-room-name").val("")
  $("#create-room-access-code").text(getLocalizedString("modal.create_room.access_code_placeholder"))
  $("#room_access_code").val(null)

  $("#createRoomModal form").attr("action", $("body").data('relative-root'))
  $("#room_mute_on_join").prop("checked", false)
  $("#room_require_moderator_approval").prop("checked", false)
  $("#room_anyone_can_start").prop("checked", false)
  $("#room_all_join_moderator").prop("checked", false)

  //show all elements & their children with a create-only class
  $(".create-only").each(function() {
    $(this).show()
    if($(this).children().length > 0) { $(this).children().show() }
  })

  //hide all elements & their children with a update-only class
  $(".update-only").each(function() {
    $(this).attr('style',"display:none !important")
    if($(this).children().length > 0) { $(this).children().attr('style',"display:none !important") }
  })
}

function showUpdateRoom(target) {
  var modal = $(target)
  var room_block_uid = modal.closest("#room-block").data("room-uid")
  $("#create-room-name").val(modal.closest("tbody").find("#room-name h4").text())
  $("#createRoomModal form").attr("action", room_block_uid + "/update_settings")

  //show all elements & their children with a update-only class
  $(".update-only").each(function() {
    $(this).show()
    if($(this).children().length > 0) { $(this).children().show() }
  })

  //hide all elements & their children with a create-only class
  $(".create-only").each(function() {
    $(this).attr('style',"display:none !important")
    if($(this).children().length > 0) { $(this).children().attr('style',"display:none !important") }
  })

  updateCurrentSettings(modal.closest("#room-block").data("room-settings"))
  
  var accessCode = modal.closest("#room-block").data("room-access-code")

  if(accessCode){
    $("#create-room-access-code").text(getLocalizedString("modal.create_room.access_code") + ": " + accessCode)
    $("#room_access_code").val(accessCode)
  } else {
    $("#create-room-access-code").text(getLocalizedString("modal.create_room.access_code_placeholder"))
    $("#room_access_code").val(null)
  }
}

function showDeleteRoom(target) {
  $("#delete-header").text(getLocalizedString("modal.delete_room.confirm").replace("%{room}", $(target).data("name")))
  $("#delete-confirm").parent().attr("action", $(target).data("path"))
}

//Update the createRoomModal to show the correct current settings
function updateCurrentSettings(settings){
  //set checkbox
  $("#room_mute_on_join").prop("checked", settings.muteOnStart)
  $("#room_require_moderator_approval").prop("checked", settings.requireModeratorApproval)
  $("#room_anyone_can_start").prop("checked", settings.anyoneCanStart)
  $("#room_all_join_moderator").prop("checked", settings.joinModerator)
}

function generateAccessCode(){
  const accessCodeLength = 6
  var validCharacters = "0123456789"
  var accessCode = ""

  for( var i = 0; i < accessCodeLength; i++){
    accessCode += validCharacters.charAt(Math.floor(Math.random() * validCharacters.length));
  }

  $("#create-room-access-code").text(getLocalizedString("modal.create_room.access_code") + ": " + accessCode)
  $("#room_access_code").val(accessCode)
}

function ResetAccessCode(){
  $("#create-room-access-code").text(getLocalizedString("modal.create_room.access_code_placeholder"))
  $("#room_access_code").val(null)
}
