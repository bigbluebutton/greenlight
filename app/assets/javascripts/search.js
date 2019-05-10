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
    var search_input = $('#search_bar');

    search_input.bind("keyup", function(){

      // Retrieve the current search query
      var search_query = search_input.find(".form-control").val();

      //Search for recordings and display them based on name match
      var recordings_found = 0;

      var recordings = $('#recording-table').find('tr');

      recordings.each(function(){
        if($(this).find('text').text().toLowerCase().includes(search_query.toLowerCase())){
          recordings_found = recordings_found + 1;
          $(this).show();
        }
        else{
          $(this).hide();
        }
      });

      // Show "No recordings match your search" if no recordings found
      if(recordings_found === 0){
        $('#no_recordings_found').show();
      }
      else{
        $('#no_recordings_found').hide();
      }
    });
  }
});
