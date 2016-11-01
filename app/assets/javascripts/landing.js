(function() {
  var recordingsTable = null;

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

    // initialize recordings datatable
    recordingsTable = $('#recordings').dataTable({
      data: [],
      rowId: 'id',
      paging: false,
      searching: false,
      info: false,
      ordering: false,
      language: {
        emptyTable: "Past recordings are shown here."
      },
      columns: [
        { title: "Date Recorded", data: "start_time" },
        { title: "Duration", data: "duration" },
        { title: "Views", data: "playbacks" },
        { title: "Actions", data: "id" }
      ],
      columnDefs: [
        {
          targets: 2,
          render: function(data, type, row) {
            if (type === 'display') {
              var str = "";
              if (row.published) {
                for(let i in data) {
                  str += '<a href="'+data[i].url+'">'+data[i].type+'</a> ';
                }
              }
              return str;
            }
            return data;
          }
        },
        {
          targets: -1,
          render: function(data, type, row) {
            if (type === 'display') {
              var roomName = window.location.pathname.split('/').pop();
              var published = row.published;
              var eye = getPublishClass(published);
              return '<button type="button" class="btn btn-default recording-update" data-id="'+data+'" data-room="'+roomName+'" data-published="'+published+'">' +
                '<i class="fa '+eye+'" aria-hidden="true"></i></button> ' +
                '<button type="button" class="btn btn-default recording-delete" data-id="'+data+'" data-room="'+roomName+'">' +
                '<i class="fa fa-trash-o" aria-hidden="true"></i></button>';
            }
            return data;
          }
        }
      ]
    });

    $('#recordings').on('click', '.recording-update', function(event) {
      var btn = $(this);
      var room = btn.data('room');
      var id = btn.data('id');
      var published = btn.data('published');
      btn.prop("disabled", true);
      $.ajax({
        method: 'PATCH',
        url: '/rooms/'+room+'/recordings/'+id,
        data: {published: (!published).toString()}
      }).done(function(data) {

      }).fail(function(data) {
        btn.prop("disabled", false);
      });
    });

    $('#recordings').on('click', '.recording-delete', function(event) {
      var room = $(this).data('room');
      var id = $(this).data('id');
      $.ajax({
        method: 'DELETE',
        url: '/rooms/'+room+'/recordings/'+id
      }).done(function() {
        recordingsTable.api().row("#"+id).remove().draw();
      });
    });

    refreshRecordings();
  };

  var refreshRecordings = function() {
    if (!recordingsTable) {
      return;
    }
    table = recordingsTable.api();
    $.get("/rooms/"+window.location.pathname.split('/').pop()+"/recordings", function(data) {
      if (!data.is_owner) {
        table.column(-1).visible( false );
      }
      var i;
      for (i = 0; i < data.recordings.length; i++) {
        var totalMinutes = Math.round((new Date(data.recordings[i].end_time) - new Date(data.recordings[i].start_time)) / 1000 / 60);
        data.recordings[i].duration = totalMinutes;

        data.recordings[i].start_time = new Date(data.recordings[i].start_time)
          .toLocaleString([], {month: 'long', day: 'numeric', year: 'numeric', hour12: 'true', hour: '2-digit', minute: '2-digit'});
      }
      table.clear();
      table.rows.add(data.recordings);
      table.columns.adjust().draw();
    });
  }

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
