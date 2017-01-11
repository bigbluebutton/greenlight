// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
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

(function() {

  var waitForModerator = function(url) {
    $.get(url + "/wait", function(html) {
      $(".center-panel-wrapper").html(html);
    });
    if (!Meeting.getInstance().getWaitingForMod()) {
      Meeting.getInstance().setWaitingForMod(true);
      if (Meeting.getInstance().getModJoined()) {
        loopJoin();
      }
    }
  };

  var init = function() {
    Meeting.clear();
    var nameInput = $('.meeting-user-name');
    if (!nameInput.val()) {
      var lastName = localStorage.getItem('lastJoinedName');
      if (lastName !== 'undefined') {
        nameInput.val(lastName);
      }
    }

    // setup event handlers
    $('.center-panel-wrapper').on ('click', '.meeting-join', function (event) {
      var name = $('.meeting-user-name').val();
      Meeting.getInstance().setName(name);
      Meeting.getInstance().setId($(".page-wrapper").data('id'));

      // a user name is set, join the user into the session
      if (name !== undefined && name !== null) {
        var jqxhr = Meeting.getInstance().getJoinMeetingResponse();
        jqxhr.done(function(data) {
          if (data.messageKey === 'wait_for_moderator') {
            waitForModerator(Meeting.getInstance().getURL());
          } else {
            $(location).attr("href", data.response.join_url);
          }
        });
        jqxhr.fail(function(xhr, status, error) {
          console.info("meeting join failed");
        });

      // if not user name was set it means we must ask for a name
      } else {
        $(location).attr("href", Meeting.getInstance().getURL());
      }
    });

    $('.center-panel-wrapper').on ('keypress', '.meeting-user-name', function (event) {
      if (event.keyCode === 13) {
        event.preventDefault();
        $('.meeting-join').click();
      }
    });

    $('.center-panel-wrapper').on ('click', '.meeting-end', function (event) {
      var jqxhr = Meeting.getInstance().endMeeting();
      var btn = $(this);
      btn.prop("disabled", true);
      jqxhr.done(function(data) {

      });
      jqxhr.fail(function(xhr, status, error) {
        console.info("meeting end failed");
      });
    });

    $('.center-panel-wrapper').on ('click', '.meeting-url-copy', function (event) {
      meetingURLInput = $('.meeting-url');

      // copy URL
      meetingURLInput.select();
      try {
        var success = document.execCommand("copy");
        if (success) {
          meetingURLInput.blur();
          $(this).trigger('hint', [$(this).data('copied-hint')]);
        } else {
          $(this).trigger('hint', [$(this).data('copy-error')]);
        }
      } catch (err) {
        $(this).trigger('hint', [$(this).data('copy-error')]);
      }
    });

    $('.center-panel-wrapper').on('hint', '.meeting-url-copy', function (event, msg) {
      $(this).focus();
      $(this).attr('title', msg)
        .tooltip('fixTitle')
        .tooltip('show')
        .attr('title', $(this).data('copy-hint'))
        .tooltip('fixTitle');
    });

    // button used to send invitations to the meeting (i.e. "mailto:" link)
    $('.center-panel-wrapper').on('click', '.meeting-invite', function (event) {
      var meetingURL = Meeting.getInstance().getURL();
      var subject = $(this).data("invite-subject");
      var body = $(this).data("invite-body").replace("&&URL&&", meetingURL);
      var mailto = "mailto:?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
      window.open(mailto);
    });

    $('.center-panel-wrapper').on('mouseleave', '.meeting-url-copy', function (event, msg) {
      $(this).blur();
    });

    $('.center-panel-wrapper').on('focus', '.meeting-url', function (event, msg) {
      $(this).select();
    });

    // only allow ctrl commands
    $('.center-panel-wrapper').on('keydown', '.meeting-url', function (event, msg) {
      if(!event.ctrlKey) {
        event.preventDefault();
      }
    });

    // enable tooltips
    var options = {
      selector: '.has-tooltip',
      container: 'body'
    };
    $(document).tooltip(options);
    var options = {
      selector: '.bottom-tooltip',
      container: 'body',
      placement: 'bottom'
    };
    $(document).tooltip(options);

    // focus name input or join button
    if ($('.meeting-user-name').is(':visible')) {
      $('.meeting-user-name').focus();
    } else {
      $('.meeting-join').focus();
    }
  };

  var initIndex = function() {
    $('.generate-link').click (function (e) {
      e.preventDefault();
      var newId = Math.trunc(Math.random() * 1000000000);
      Meeting.getInstance().setId(newId);
      $(".page-wrapper.meetings").data('id', newId);
      $('.meeting-url').val(Meeting.getInstance().getURL());
    });

    $('.generate-link').click();

    $('ul.previously-joined').empty();
    var joinedMeetings = localStorage.getItem('joinedMeetings');
    if (joinedMeetings && joinedMeetings.length > 0) {
      joinedMeetings = joinedMeetings.split(',');
      $('.center-panel-wrapper .panel-footer').removeClass('hidden');

      for (var i = joinedMeetings.length - 1; i >= 0; i--) {
        $('ul.previously-joined').append('<li><a href="/meetings/'+joinedMeetings[i]+'">'+joinedMeetings[i]+'</a></li>');
      }
    }
  };

  var initMeetings = function() {
    $('.meeting-url').val(Meeting.getInstance().getURL());
  };

  var initRooms = function() {
    displayRoomURL();

    Recordings.getInstance().refresh();
    Recordings.getInstance().setupActionHandlers();
  };

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller=landing]").get(0)) {
      init();
      if ($("body[data-action=index]").get(0)) {
        initIndex();
      } else if ($("body[data-action=meetings]").get(0)) {
        initMeetings();
      } else if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
