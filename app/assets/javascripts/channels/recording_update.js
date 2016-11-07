(function() {

  var initRooms = function() {
    App.messages = App.cable.subscriptions.create({
      channel: 'RecordingUpdatesChannel',
      username: getRoomName()
    },
    {
      received: function(data) {
        var table = $("#recordings").DataTable();
        var rowData = table.row("#"+data.record_id).data();
        rowData.published = data.published
        table.row("#"+data.record_id).data(rowData).draw();
        var publish = (data.published) ? 'publish' : 'unpublish';

        // show alert success alert
        $('.alert-template .alert-message').html($('.'+publish+'-alert').html());
        $('#alerts').html($('.alert-template').html());
        setTimeout(function() {
          $('#alerts > .alert').alert('close');
        }, 4000);
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
