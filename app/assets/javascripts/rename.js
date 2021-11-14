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

  if(controller == "rooms" && action == "show" 
    || controller == "rooms" && action == "update" 
    || controller == "users" && action == "recordings" 
    || controller == "admins" && action == "server_recordings"){

    // Set a room header rename event
    var configure_room_header = function(room_title){

      function register_room_title_event(e){
        // Remove current window events
        $(window).off('mousedown keydown');

        if(e.type == 'focusout'){
          submit_rename_request(room_title);
          return;
        }

        room_title.addClass("dotted_underline");
        room_title.find('#user-text').fadeTo('medium', 0.7);
        room_title.find('#user-text').attr("contenteditable", true);
        room_title.find('#user-text').focus();

        // Stop automatic refresh
        e.preventDefault();

        register_window_event(room_title, 'user-text', '#edit-room', 'edit-room');
      }

      room_title.find('#user-text').on('dblclick focusout', function(e){
        if(room_title.find('#edit-room').length){
          register_room_title_event(e);
        }
      });

      room_title.find('.fa-edit').on('click', function(e){
        register_room_title_event(e);
      });
    }

    // Set a recording row rename event
    var configure_recording_row = function(recording_title){

      function register_recording_title_event(e){
        // Remove current window events
        $(window).off('mousedown keydown');

        if(e.type == 'focusout'){
          submit_rename_request(recording_title);
          return;
        }

        recording_title.addClass("dotted_underline");
        recording_title.fadeTo('medium', 0.7);
        recording_title.find('span').attr("contenteditable", true);
        recording_title.find('span').focus();

        // Stop automatic refresh
        e.preventDefault();

        register_window_event(recording_title, 'recording-text', '#edit-record', 'edit-recordid');
      }

      recording_title.find('a').on('click focusout', function(e){
        register_recording_title_event(e);
      });

      recording_title.find('#recording-text').on('dblclick focusout', function(e){
        register_recording_title_event(e);
      });
    }

    // Register window event to submit new name
    // upon click or upon pressing the enter key
    var register_window_event = function(element, textfield_id, edit_button_id, edit_button_data){
      $(window).on('mousedown keydown', function(clickEvent){

        // Return if the text is clicked
        if(clickEvent.type == "mousedown" && clickEvent.target.id == textfield_id){
          return;
        }

        // Return if the edit icon is clicked
        if(clickEvent.type == "mousedown" && $(clickEvent.target).is(edit_button_id) &&
          $(clickEvent.target).data(edit_button_data) === element.find(edit_button_id).data(edit_button_data)){
          return;
        }

        // Check if event is keydown and enter key is not pressed
        if(clickEvent.type == "keydown" && clickEvent.which !== 13){
          return;
        }

        clickEvent.preventDefault();
        submit_rename_request(element);

        // Remove window event when ajax call to update name is submitted
        $(window).off('mousedown keydown');
      });
    }

    // Apply ajax request depending on the element that triggered the event
    var submit_rename_request = function(element){
      if(element.is('#room-title')){
        submit_update_request({
          setting: "rename_header",
          name: element.find('#user-text').text(),
        }, element.data('path'), "POST");
      }
      else if(element.is('#recording-title')){
        submit_update_request({
          setting: "rename_recording",
          record_id: element.data('recordid'),
          record_name: element.find('span').text(),
          room_uid: element.data('room-uid'),
        }, element.data('path'), "PATCH");
      }
    }

    // Helper for submitting ajax requests
    var submit_update_request = function(data, path, action){
      // Send ajax request for update
      $.ajax({
        url: path,
        type: action,
        data: data,
      });
    }

    // Elements that can be renamed
    var room_title = $('#room-title');
    var recording_rows = $('#recording-table').find('tr');

    // Configure renaming for room header
    configure_room_header(room_title);

    // Configure renaming for recording rows
    recording_rows.each(function(){
      var recording_title = $(this).find('#recording-title');
      configure_recording_row(recording_title);
    });
  }
});
