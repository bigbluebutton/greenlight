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

    // Choose active header
    // (Name, Length or Users)
    $('th').each(function(){
      if($(this).data("header")){
        $(this).on('click', function(){    
          set_active_header($(this).data("header"));
          sort_by($(this).data("header"), $(this).data('order'));
        });
      }
    });

    // Based on the header (Name, Length or Users) clicked,
    // Modify the ui for the tables
    var set_active_header = function(active_header){
      $('th').each(function(){
        if($(this).data("header") == active_header){
          configure_order($(this));
        }
        else{
          $(this).text($(this).data("header"));
          $(this).data('order', 'none');
        }
      });
    }

    // Based on the header (Name, Length or Users) clicked,
    // Modify the ui for the tables
    var configure_order = function(header_elem){
      if(header_elem.data('order') === 'asc'){ // asc
        header_elem.text(header_elem.data("header") + " ↓");
        header_elem.data('order', 'desc');
      }
      else if(header_elem.data('order') === 'desc'){ // desc
        header_elem.text(header_elem.data("header"));
        header_elem.data('order', 'none');
      }
      else{ // none
        header_elem.text(header_elem.data("header") + " ↑");
        header_elem.data('order', 'asc');
      }
    }

    // Given a label and an order, sort recordings by order
    // under a given label
    var sort_by = function(label, order){
      var recording_list_tbody = $('.table-responsive').find('tbody');
      if(label === "Name"){
        sort_recordings(recording_list_tbody, order, "#recording-title");
      }
      else if(label === "Length"){
        sort_recordings(recording_list_tbody, order, "#recording-length");
      }
      else if(label === "Users"){
        sort_recordings(recording_list_tbody, order, "#recording-users");
      }
    }

    // Generalized function for sorting recordings
    var sort_recordings = function(recording_list_tbody, order, recording_id){
      recording_list_tbody.find('tr').sort(function(a, b){
        var a_val = $.trim($(a).find(recording_id).text());
        var b_val = $.trim($(b).find(recording_id).text());

        if(order === "asc"){
          return a_val.localeCompare(b_val);
        }
        else if(order === "desc"){
          return b_val.localeCompare(a_val);
        }
      }).appendTo(recording_list_tbody);
    }
  }
});
