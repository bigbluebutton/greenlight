// Recordings class

var _recordingsInstance = null;

class Recordings {
  constructor() {
    // configure the datatable for recordings
    this.table = $('#recordings').dataTable({
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
          targets: 0,
          render: function(data, type, row) {
            if (type === 'display') {
              return new Date(data)
                .toLocaleString($('html').attr('lang'),
                  {month: 'long', day: 'numeric', year: 'numeric',
                  hour12: 'true', hour: '2-digit', minute: '2-digit'});
            }
            return data;
          }
        },
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
              var roomName = Meeting.getInstance().getId();
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
  }

  // Gets the current instance or creates a new one
  static getInstance() {
    if (_recordingsInstance && Recordings.initialized()) {
      return _recordingsInstance;
    }
    _recordingsInstance = new Recordings();
    return _recordingsInstance;
  }

  static initialize() {
    Recordings.getInstance();
  }

  static initialized() {
    return $.fn.DataTable.isDataTable('#recordings') && _recordingsInstance;
  }

  // refresh the recordings from the server
  refresh() {
    var _this = this;
    var table_api = this.table.api();
    $.get("/rooms/"+Meeting.getInstance().getId()+"/recordings", function(data) {
      if (!data.is_owner) {
        table_api.column(-1).visible(false);
      }
      var i;
      for (i = 0; i < data.recordings.length; i++) {
        var totalMinutes = Math.round((new Date(data.recordings[i].end_time) - new Date(data.recordings[i].start_time)) / 1000 / 60);
        data.recordings[i].duration = totalMinutes;
      }
      data.recordings.sort(function(a,b) {
        return new Date(b.start_time) - new Date(a.start_time);
      });
      table_api.clear();
      table_api.rows.add(data.recordings);
      table_api.columns.adjust().draw();
    });
  }

  // setup click handlers for the action buttons
  setupActionHandlers() {
    var table_api = this.table.api();
    this.table.on('click', '.recording-update', function(event) {
      var btn = $(this);
      var row = table_api.row($(this).closest('tr')).data();
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

    this.table.on('click', '.recording-delete', function(event) {
      var btn = $(this);
      var row = table_api.row($(this).closest('tr')).data();
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
  }
}
