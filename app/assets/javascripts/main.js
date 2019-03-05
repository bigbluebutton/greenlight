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

// Handle changing of settings tabs.
$(document).on('turbolinks:load', function(){
  var controller = $("body").data('controller');
  var action = $("body").data('action');


  // Only run on the main page.
  if (controller == "main" && action == "index"){
    var cycleImages = function(){
      var images = $('.img-cycle img');
      var now = images.filter(':visible');
      var next = now.next().length ? now.next() : images.first();
      var speed = 1500;

      now.fadeOut(speed);
      next.fadeIn(speed);
    }

    $(function() {
      setInterval(cycleImages, 5000);
    });
  }
});
