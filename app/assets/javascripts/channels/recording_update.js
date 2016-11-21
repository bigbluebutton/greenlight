(function() {

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'RecordingUpdatesChannel',
      encrypted_id: Meeting.getInstance().getId()
    },
    {
      received: function(data) {
        var recordings = Recordings.getInstance();
        var table = recordings.table.api()
        var row = table.row("#"+data.record_id);
        if (data.action === 'update') {
          var rowData = row.data();
          rowData.published = data.published
          table.row("#"+data.record_id).data(rowData);
          recordings.draw();

          var published = (data.published) ? 'published' : 'unpublished';
          showAlert(I18n['recording_'+published], 4000);
        } else if (data.action === 'delete') {
          row.remove();
          recordings.draw();

          showAlert(I18n.recording_deleted, 4000);
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
