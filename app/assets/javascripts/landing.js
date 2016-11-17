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

    // setup event handlers
    $('.center-panel-wrapper').on ('click', '.meeting-join', function (event) {
      var name = $('.meeting-user-name').val();
      Meeting.getInstance().setName(name);
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
    $(document).tooltip(options)
    var options = {
      selector: '.bottom-tooltip',
      container: 'body',
      placement: 'bottom'
    };
    $(document).tooltip(options);

    // enable popovers
    var options = {
      selector: '.has-popover',
      container: 'body',
      html: true,
      trigger: 'focus',
      title: function() {
        return I18n.are_you_sure;
      },
      content: function() {
        return $(".delete-popover-body").html();
      }
    };
    $('#recordings').popover(options);

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
      $(".page-wrapper.meetings").data('id', newId);
      var link = window.location.protocol +
        '//' +
        window.location.hostname +
        '/meetings/' +
        newId;
      $('.meeting-url').val(link);
    });

    if (meetingId = $(".page-wrapper.meetings").data('id')) {
      var link = window.location.protocol +
        '//' +
        window.location.hostname +
        '/meetings/' +
        meetingId;
      $('.meeting-url').val(link)
    } else {
      $('.generate-link').click();
    }
  };

  var initRooms = function() {
    displayRoomURL();

    Recordings.getInstance().refresh();
    Recordings.getInstance().setupActionHandlers();
  };

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller=landing]").get(0)) {
      init();
      if ($("body[data-action=meetings]").get(0)) {
        initIndex();
      } else if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
