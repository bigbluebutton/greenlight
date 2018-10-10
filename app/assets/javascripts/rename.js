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

  if(controller == "rooms" && action == "show" || controller == "rooms" && action == "update"){

    // Renaming room blocks
    // Bind a rename event for each room block
    var room_blocks = $('#room_block_container').find('.card');

    room_blocks.each(function(){

      var room_block = $(this)

      if(!room_block.is('#home_room_block')){

        // Register a click event on each room_block rename dropdown
        room_block.find('#rename-room-button').bind('click', function(e){

          room_block.find('#room-name').hide();
          room_block.find('#room-name-editable').show();
          room_block.find('#room-name-editable-input').select()

          // Stop automatic refresh
          e.preventDefault();

          // Register window event to submit new name
          // upon click or upon pressing the enter key
          $(window).on('mousedown keypress', function(clickEvent){
            
            // Check if event is keypress and enter key is pressed
            if(clickEvent.type != "mousedown" && clickEvent.which !== 13){
              return
            }

            // Send ajax request for update
            $.ajax({
              url: window.location.pathname,
              type: "PATCH",
              data:{
                setting: "rename_block",
                room_block_uid: room_block.data('room-uid'),
                room_name: room_block.find('#room-name-editable-input').val(),
              },
              success: function(data){
                console.log("Success");
              },
            });

            // Remove window event when ajax call to update name is submitted
            $(window).off('mousedown keypress');
          });
        });
      }
    });

    // Renaming room by header
    // Bind a click event to the edit button
    var room_title = $('#room-title')
    
    room_title.find('a').on('click', function(e){

      room_title.find('#user-text').fadeTo('medium', 0.7);
      room_title.find('#user-text').attr("contenteditable", true);
      room_title.find('#user-text').focus();
        
      // Stop automatic refresh
      e.preventDefault();

      // Register window event to submit new name
      // upon click or upon pressing the enter key
      $(window).on('mousedown keypress', function(clickEvent){

        // Return if the text element is clicked
        if(clickEvent.type == "mousedown" && clickEvent.target.id == 'user-text'){
          return
        }

        // Return if event is keypress and enter key isn't pressed
        if(clickEvent.type == "keypress" && clickEvent.which !== 13){
          return
        }

        // Send ajax request for update
        $.ajax({
          url: window.location.pathname,
          type: "PATCH",
          data:{
            setting: "rename_header",
            room_name: room_title.find('#user-text').text(),
          },
          success: function(data){
            console.log("Success");
          },
        });

        // Remove window event when ajax call to update name is submitted
        $(window).off('mousedown keypress');
      });
    });

    // Renaming recordings by block
    // Bind a click event to the edit button for each recording
    recording_rows = $('#recording-table').find('tr');

    recording_rows.each(function(){

      // Bind each recording edit button to an event
      var recording_title = $(this).find('#recording-title');

      recording_title.find('a').on('click', function(e){

        recording_title.fadeTo('medium', 0.7);
        recording_title.find('text').attr("contenteditable", true);
        recording_title.find('text').focus();
        
        // Stop automatic refresh
        e.preventDefault();
        
        // Register window event to submit new name
        // upon click or upon pressing the enter key
        $(window).on('mousedown keypress', function(clickEvent){

          //alert(clickEvent.target);
          //alert(recording_title.data('recordid'));
          
          // Return if the text element is clicked
          if(clickEvent.type == "mousedown" && clickEvent.target.id == 'recording-text'){ //data('recordid') == recording_title.data('recordid')){
            return
          }

          // Return if event is keypress and enter key isn't pressed
          if(clickEvent.type == "keypress" && clickEvent.which !== 13){
            return
          }

          // Send ajax request for update
          $.ajax({
            url: window.location.pathname,
            type: "PATCH",
            data:{
              setting: "rename_recording",
              record_id: recording_title.data('recordid'),
              record_name: recording_title.find('text').text(),
            },
            success: function(data){
              //alert(data);
              //alert("Success");
              console.log("Success");
            },
          });

          // Remove window event when ajax call to update name is submitted
          $(window).off('mousedown keypress');
        });
      });
    });
  }
});