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

    $('.edit-recording-modal').each(function(){

      var tag_list_input = $(this).find('.tag-list-tokenfield')
      var tag_list_data = $(this).find(".tag-list");

      tag_list_input.tokenfield();
      tag_list_input.on('tokenfield:createtoken', function (event) {
        var existingTokens = $(this).tokenfield('getTokens');

        $.each(existingTokens, function(index, token) {
          if (token.value === event.attrs.value){
            $('.token').fadeOut(10).fadeIn(10);
            event.preventDefault();
          }
        });
      });

      $(this).find('.edit-recording-submit').on('click', function(){
        tag_list_data.val(tag_list_input.val());
      });
    });
  }
});