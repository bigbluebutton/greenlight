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

  if ((controller == "admins" && action == "index") || 
      (controller == "rooms" && action == "show") || 
      (controller == "rooms" && action == "update") ||
      (controller == "rooms" && action == "join") || 
      (controller == "users" && action == "recordings")) {
    // Submit search if the user hits enter
    $("#search-input").keypress(function(key) {
      var keyPressed = key.which
      if (keyPressed == 13) {
        searchPage()
      }
    })

    // Add listeners for sort
    $("th[data-order]").click(function(data){
      var header_elem = $(data.target)
      var controller = $("body").data('controller');
      var action = $("body").data('action');

      if(header_elem.data('order') === 'asc'){ // asc
        header_elem.data('order', 'desc');
      }
      else if(header_elem.data('order') === 'desc'){ // desc
        header_elem.data('order', 'none');
      }
      else{ // none
        header_elem.data('order', 'asc');
      }

      var search = $("#search-input").val();

      if(controller === "rooms" && action === "show"){
        window.location.replace(window.location.pathname + "?page=1&search=" + search + 
          "&column=" + header_elem.data("header") + "&direction="+ header_elem.data('order') + 
          "#recordings-table");
      }
      else{
        window.location.replace(window.location.pathname + "?page=1&search=" + search + 
          "&column=" + header_elem.data("header") + "&direction="+ header_elem.data('order'));
      }
    })

    if(controller === "rooms" && action === "show"){
      $(".page-item > a").each(function(){
        if(!$(this).attr('href').endsWith("#")){
          $(this).attr('href', $(this).attr('href') + "#recordings-table")
        }
      })
    }
  }
})

// Searches the user table for the given string
function searchPage() {
  var search = $("#search-input").val();

  var controller = $("body").data('controller');
  var action = $("body").data('action');

  if(controller === "rooms" && action === "show"){
    window.location.replace(window.location.pathname + "?page=1&search=" + search + "#recordings-table");
  } else{
    window.location.replace(window.location.pathname + "?page=1&search=" + search);
  }
  
}

// Clears the search bar
function clearSearch() {
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  if(controller === "rooms" && action === "show"){
    window.location.replace(window.location.pathname + "?page=1"  + "#recordings-table");
  } else{
    window.location.replace(window.location.pathname + "?page=1");
  }
}
