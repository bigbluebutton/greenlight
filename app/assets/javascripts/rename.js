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
            $(window).on('mousedown keypress', function(e){
              
              // Check if event is keypress and enter key is pressed
              if(e.type != "mousedown" && e.which !== 13){
                return
              }

              room_update_url = "/" + room_block.data('room-uid');

              // Send ajax request for update
              $.ajax({
                url: room_update_url,
                type: "PATCH",
                data:{
                  setting: "rename",
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

        room_title.find('#user-text').attr("contenteditable", true);
        room_title.find('#user-text').focus();
          
        // Stop automatic refresh
        e.preventDefault();

        // Register window event to submit new name
        // upon click or upon pressing the enter key
        $(window).on('mousedown keypress', function(e){
          
          // Check if event is keypress and enter key is pressed
          if(e.type != "mousedown" && e.which !== 13){
            return
          }

          // Send ajax request for update
          $.ajax({
            url: window.location.pathname,
            type: "PATCH",
            data:{
              setting: "rename",
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

    }
  });