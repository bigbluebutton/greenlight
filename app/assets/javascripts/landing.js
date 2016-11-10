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

    $('.center-panel-wrapper').on ('click', '.meeting-join', function (event) {
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
      meetingURL = $('.meeting-url');
      meetingURL.select();
      document.execCommand("copy");
      meetingURL.blur();
    });

    // enable popovers
    var options = {
      selector: '.has-popover',
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
    displayMeetingURL();

    // initialize recordings datatable
    recordingsTable = $('#recordings').dataTable({
      data: [],
      rowId: 'id',
      paging: false,
      searching: false,
      info: false,
      order: [[ 0, "desc" ]],
      language: {
        emptyTable: " "
      },
      columns: [
        { data: "start_time" },
        { data: "previews" },
        { data: "duration" },
        { data: "playbacks" },
        { data: "id" }
      ],
      columnDefs: [
        {
          targets: 1,
          render: function(data, type, row) {
            if (type === 'display') {
              var str = '';
              for(let i in data) {
                str += '<img height="50" width="50" src="'+data[i].url+'" alt="'+data[i].alt+'"></img> ';
              }
              return str;
            }
            return data;
          }
        },
        {
          targets: 3,
          render: function(data, type, row) {
            if (type === 'display') {
              var str = '';
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
              var roomName = getEncryptedId();
              var published = row.published;
              var eye = getPublishClass(published);
              return '<button type="button" class="btn btn-default recording-update" data-published="'+published+'">' +
                '<i class="fa '+eye+'" aria-hidden="true"></i></button> ' +
                '<a tabindex="0" role="button" class="btn btn-default has-popover"' +
                  'data-toggle="popover" data-placement="top">' +
                    '<i class="fa fa-trash-o" aria-hidden="true"></i>' +
                '</a>';
            }
            return data;
          }
        }
      ]
    });

    $('#recordings').on('click', '.recording-update', function(event) {
      var btn = $(this);
      var row = recordingsTable.api().row($(this).closest('tr')).data();
      var url = $('.meeting-url').val();
      var id = row.id;
      var published = btn.data('published');
      btn.prop('disabled', true);
      $.ajax({
        method: 'PATCH',
        url: url+'/recordings/'+id,
        data: {published: (!published).toString()}
      }).done(function(data) {

      }).fail(function(data) {
        btn.prop('disabled', false);
      });
    });

    $('#recordings').on('click', '.recording-delete', function(event) {
      var btn = $(this);
      var row = recordingsTable.api().row($(this).closest('tr')).data();
      var url = $('.meeting-url').val();
      var id = row.id;
      btn.prop('disabled', true);
      $.ajax({
        method: 'DELETE',
        url: url+'/recordings/'+id
      }).done(function() {

      }).fail(function(data) {
        btn.prop('disabled', false);
      });
    });

    refreshRecordings();
  };

  var refreshRecordings = function() {
    if (!recordingsTable) {
      return;
    }
    table = recordingsTable.api();
    $.get("/rooms/"+getEncryptedId()+"/recordings", function(data) {
      if (!data.is_owner) {
        table.column(-1).visible( false );
      }
      var i;
      for (i = 0; i < data.recordings.length; i++) {
        var totalMinutes = Math.round((new Date(data.recordings[i].end_time) - new Date(data.recordings[i].start_time)) / 1000 / 60);
        data.recordings[i].duration = totalMinutes;

        data.recordings[i].start_time = new Date(data.recordings[i].start_time)
          .toLocaleString($('html').attr('lang'),
            {month: 'long', day: 'numeric', year: 'numeric', hour12: 'true', hour: '2-digit', minute: '2-digit'});
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
