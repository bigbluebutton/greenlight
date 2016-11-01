(function() {

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'ModeratorJoinsChannel',
      username: getRoomName()
    },
    {
      received: function(data) {
        if (!Meeting.getInstance().getModJoined()) {
          Meeting.getInstance().setModJoined(true);
          if (Meeting.getInstance().getWaitingForMod()) {
            loopJoin();
          }
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
