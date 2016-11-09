(function() {

  var sessionStatusRefresh = function(url) {
    $.get(url + "/session_status_refresh", function(html) {
      $(".center-panel-wrapper").html(html);
      displayMeetingURL();
    });
  }

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'MeetingUpdatesChannel',
      encrypted_id: getEncryptedId()
    },
    {
      received: function(data) {
        if (data.action === 'moderator_joined') {
          if (!Meeting.getInstance().getModJoined()) {
            Meeting.getInstance().setModJoined(true);
            if (Meeting.getInstance().getWaitingForMod()) {
              loopJoin();
            } else {
              sessionStatusRefresh($('.meeting-url').val());
              showAlert($('.meeting-started-alert').html(), 4000);
            }
          }
        } else if (data.action === 'meeting_ended') {
          sessionStatusRefresh($('.meeting-url').val());
          showAlert($('.meeting-ended-alert').html(), 4000);
        }
      }
    });
  };

  $(document).on("turbolinks:load", function() {
    if ($("body[data-controller=landing]").get(0)) {
      if ($("body[data-action=rooms]").get(0)) {
        initRooms();
      }
    }
  });
}).call(this);
