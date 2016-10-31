(function() {

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'RecordingUpdatesChannel',
      username: window.location.pathname.split('/').pop()
    },
    {
      received: function(data) {
        var btn = $("#recordings").find(".recording-update:disabled");
        btn.data('published', data.published);
        btn.find('i').removeClass(getPublishClass(!data.published));
        btn.find('i').addClass(getPublishClass(data.published));
        btn.prop("disabled", false);
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
