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
      var room_blocks = $('#room_block_container').find('.card');

      var editable = false;

      // Bind a rename event for each room block
      room_blocks.each(function(){

        var room_block = $(this)
        // Register a click event on each room_block rename dropdown
        if(!room_block.is('#home_room_block')){
          //alert("This will work");
        
          room_block.find('#rename-room-button').bind('click', function(e){

            //alert(room_block.find('#room-name'));
            room_block.find('#room-name').hide();
            room_block.find('#room-name-editable').show();
            room_block.find('#room-name-editable-input').select()

            //alert($(this).find('#room-name'));
            //alert("Rename activated");

            e.preventDefault();

            // Register one time window event to submit new name
            $(window).one('mousedown', function(){
              // Apply ajax request
              // alert("GOOD");

              room_update_url = "/" + room_block.data('room-uid');
              // alert(room_update_url);

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
            });
          });
        }
      });
    }
  });