(function() {

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'RecordingUpdatesChannel',
      username: window.location.pathname.split('/').pop()
    },
    {
      received: function(data) {
        var table = $("#recordings").DataTable();
        var rowData = table.row("#"+data.record_id).data();
        rowData.published = data.published
        table.row("#"+data.record_id).data(rowData).draw();
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
