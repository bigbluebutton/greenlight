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

    $('.meeting-join').click (function (event) {
      var url = $('.meeting-url').val();
      var name = $('.meeting-user-name').val();
      Meeting.getInstance().setURL(url);
      Meeting.getInstance().setName(name);
      var jqxhr = Meeting.getInstance().getjoinMeetingURL();

      jqxhr.done(function(data) {
        if (data.messageKey === 'wait_for_moderator') {
          waitForModerator(url);
        } else {
          $(location).attr("href", data.response.join_url);
        }
      });
      jqxhr.fail(function(xhr, status, error) {
        console.info("meeting join failed");
      });
    });

    $('.meeting-url-copy').click (function (e) {
      meetingURL = $('.meeting-url');
      meetingURL.select();
      document.execCommand("copy");
      meetingURL.blur();
    });
  };

  var initIndex = function() {

    $('.generate-link').click (function (e) {
      e.preventDefault();
      var link = window.location.protocol +
        '//' +
        window.location.hostname +
        '/meetings/' +
        Math.trunc(Math.random() * 1000000000);

      $('.meeting-url').val(link);
    });

    if (meetingId = $('.meeting-url').data('meetingId')) {
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
    meetingURL = $('.meeting-url');
    var link = window.location.protocol +
      '//' +
      window.location.hostname +
      meetingURL.data('path');
    meetingURL.val(link);
  };

  $(document).on("turbolinks:load", function() {
    init();
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=meetings]").get(0)) {
        initIndex();
      } else if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
