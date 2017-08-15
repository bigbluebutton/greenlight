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

/** global: Meeting */
/** global: PreviousMeetings */
/** global: QRCode */
/** global: Recordings */
/** global: Turbolinks */

(function() {

  var qrcode;

  var waitForModerator = function(url) {
    window.localStorage.setItem("waitingName", $('.meeting-user-name').val());
    $.post(url + "/wait", {name: $('.meeting-user-name').val()}, function(html) {
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
      var lastName = window.localStorage.getItem('lastJoinedName');
      if (lastName !== 'undefined') {
        nameInput.val(lastName);
      }
    }

    // setup event handlers
    $('.center-panel-wrapper').on ('click', '.meeting-join', function () {
      var name = $('.meeting-user-name').val();
      Meeting.getInstance().setUserName(name);
      Meeting.getInstance().setMeetingId($(".page-wrapper").data('id'));

      // a user name is set, join the user into the session
      if (name !== undefined && name !== null) {
        var jqxhr = Meeting.getInstance().getJoinMeetingResponse();
        if (jqxhr) {
          jqxhr.done(function(data) {
            if (data.messageKey === 'wait_for_moderator') {
              waitForModerator(Meeting.getInstance().getURL());
            } else {
              $(location).attr("href", data.response.join_url);
            }
          });
          jqxhr.fail(function() {
            console.info("meeting join failed");
          });
        } else {
          $('.meeting-user-name').parent().addClass('has-error');
        }

      // if not user name was set it means we must ask for a name
      } else {
        $(location).attr("href", Meeting.getInstance().getURL());
      }
    });

    $('.center-panel-wrapper').on ('click', '.meeting-start', function () {
      Turbolinks.visit($('.meeting-url').val());
    });

    $('.center-panel-wrapper').on ('input', '.meeting-user-name', function () {
      if ($(this).val() === '') {
        $(this).parent().addClass('has-error')
      } else {
        $(this).parent().removeClass('has-error')
      }
    });

    $('.center-panel-wrapper').on ('keypress', '.meeting-user-name', function (event) {
      if (event.keyCode === 13) {
        event.preventDefault();
        $('.meeting-join').click();
      }
    });

    $('.center-panel-wrapper').on ('keypress', '.meeting-name', function (event) {
      if (event.keyCode === 13) {
        event.preventDefault();
        $('.meeting-start').click();
      }
    });

    $('.center-panel-wrapper').on ('click', '.meeting-end', function () {
      var jqxhr = Meeting.getInstance().endMeeting();
      var btn = $(this);
      btn.prop("disabled", true);
      jqxhr.fail(function() {
        console.info("meeting end failed");
      });
    });

    $('.center-panel-wrapper').on ('click', '.meeting-url-copy', function () {
      var meetingURLInput = $('.meeting-url');

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

    $('.center-panel-wrapper').on('mouseleave', '.meeting-url-copy', function () {
      $(this).blur();
    });

    // button used to send invitations to the meeting (i.e. "mailto:" link)
    $('.center-panel-wrapper').on('click', '.meeting-invite', function () {
      var meetingURL = Meeting.getInstance().getURL();
      var subject = $(this).data("invite-subject");
      var body = $(this).data("invite-body").replace("&&URL&&", meetingURL);
      var mailto = "mailto:?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
      window.open(mailto);
    });

    $('.center-panel-wrapper').on ('click', '.meeting-url-qrcode', function () {
      var meetingURL;

      try {
        meetingURL = $('.meeting-url').val();
        if ($('.meeting-url-qrcode-group').is(':empty')) {
          // generate code
          qrcode = new QRCode($(".meeting-url-qrcode-group")[0], {
                text: meetingURL,
                width: 128,
                height: 128,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
              });
        } else {
          // clear the code.
          qrcode.clear();
          // make another code.
          qrcode.makeCode(meetingURL);
        }
        $(this).trigger('hint', [$(this).data('qrcode-generated-hint')]);
      } catch (err) {
        $(this).trigger('hint', [$(this).data('qrcode-generate-error')]);
      }
    });

    $('.center-panel-wrapper').on('hint', '.meeting-url-qrcode', function (event, msg) {
      $(this).focus();
      $(this).attr('title', msg)
        .tooltip('fixTitle')
        .tooltip('show')
        .attr('title', $(this).data('qrcode-generate-hint'))
        .tooltip('fixTitle');
    });

    $('.center-panel-wrapper').on('mouseleave', '.meeting-url-qrcode', function () {
      $(this).blur();
    });

    $('.center-panel-wrapper').on('focus', '.meeting-url', function () {
      $(this).select();
    });

    // only allow ctrl commands
    $('.center-panel-wrapper').on('keydown', '.meeting-url', function (event) {
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
    options = {
      selector: '.bottom-tooltip',
      container: 'body',
      placement: 'bottom'
    };
    $(document).tooltip(options);

    // focus name input or join button
    if ($('.meeting-name').is(':visible')) {
      $('.meeting-name').focus();
    } else if ($('.meeting-user-name').is(':visible')) {
      $('.meeting-user-name').focus();
    } else {
      $('.meeting-join').focus();
    }
  };

  var initIndex = function() {

    $('.center-panel-wrapper').on('input', '.meeting-name', function () {
      var newId = $(this).val();
      Meeting.getInstance().setMeetingId(newId);
      $(".page-wrapper.meetings").data('id', newId);
      $('.meeting-url').val(Meeting.getInstance().getURL());
      $('.join-meeting-title').text('"'+newId+'"');
      if (newId === '') {
        $('.invite-join-wrapper').addClass('hidden');
      } else {
        $('.invite-join-wrapper').removeClass('hidden');
      }
      if (!$('.meeting-url-qrcode-group').is(':empty')) {
        $('.meeting-url-qrcode-group').empty();
      }
    });

    PreviousMeetings.init('joinedMeetings');
  };

  var initMeetings = function() {
    $('.meeting-url').val(Meeting.getInstance().getURL());
  };

  var initRooms = function() {
    displayRoomURL();
    var roomAdmin = $('.page-wrapper.rooms').data('admin-id');

    $('.center-panel-wrapper').on('input', '.meeting-name', function () {
      var newId = $(this).val();
      Meeting.getInstance().setMeetingId(newId);
      $('.meeting-url').val(Meeting.getInstance().getURL());
      $('.join-meeting-title').text('"'+newId+'"');
      if (newId === '') {
        $('.invite-join-wrapper').addClass('hidden');
      } else {
        $('.invite-join-wrapper').removeClass('hidden');
      }
      if (!$('.meeting-url-qrcode-group').is(':empty')) {
        $('.meeting-url-qrcode-group').empty();
      }
    });

    if ($(".page-wrapper.rooms").data('main-room')) {
      PreviousMeetings.init('joinedRooms-'+roomAdmin);

      if ($('input.meeting-name').val() !== '') {
        $('input.meeting-name').trigger('input');
      }
    }

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
