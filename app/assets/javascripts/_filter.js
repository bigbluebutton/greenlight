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

  if(controller == "rooms" && action == "show"){

    // Upon change to filter category dropdown, show the correct filter dropdown
    // for the category
    $('.filter_category').on('change', function(){
      $("#filter_recordings").find(".filter_dropdown").each(function(){
        $(this).hide();
      });

      filter_value = $(this).find(":selected").data("filter-opt");
      $("#filter_recordings").find(`[data-filter-opt='${filter_value}']`).show();
    });

    //
    $('#filter_recordings').find(".filter_dropdown").each(function(){
      $(this).on('change', function(){
        category_data = $('.filter_category').find(":selected").data("filter-opt");
        select_data = $(this).find(":selected").data("value");

        alert(category_data);
        alert(select_data);
      });
    });
  }
});