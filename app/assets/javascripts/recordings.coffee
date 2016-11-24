# Recordings class

_recordingsInstance = null

class @Recordings
  constructor: ->
    # configure the datatable for recordings
    this.table = $('#recordings').dataTable({
      data: [],
      rowId: 'id',
      paging: false,
      dom: 't',
      info: false,
      order: [[ 0, "desc" ]],
      language: {
        emptyTable: I18n.no_recordings,
        zeroRecords: I18n.no_recordings
      },
      columns: [
        { data: "start_time" },
        { data: "previews", orderable: false },
        { data: "duration" },
        { data: "playbacks", orderable: false },
        { data: "published", visible: false },
        { data: "id", orderable: false }
      ],
      columnDefs: [
        {
          targets: 0,
          render: (data, type, row) ->
            if type == 'display'
              return new Date(data)
                .toLocaleString($('html').attr('lang'),
                  {month: 'long', day: 'numeric', year: 'numeric',
                  hour12: 'true', hour: '2-digit', minute: '2-digit'})
            return data
        },
        {
          targets: 1,
          render: (data, type, row) ->
            if type == 'display'
              str = ''
              if row.published
                for d in data
                  str += '<img height="50" width="50" src="'+d.url+'" alt="'+d.alt+'"></img> '
              return str
            return data
        },
        {
          targets: 3,
          render: (data, type, row) ->
            if type == 'display'
              str = ''
              if row.published
                for d in data
                  str += '<a href="'+d.url+'" target="_blank">'+d.type_i18n+'</a> '
              return str
            return data
        },
        {
          targets: -1,
          render: (data, type, row) ->
            if type == 'display'
              roomName = Meeting.getInstance().getId()
              published = row.published
              publishText = if published then 'unpublish' else 'publish'
              recordingActions = $('.hidden-elements').find('.recording-actions')
              recordingActions.find('.recording-update > i.default')
                .removeClass(PUBLISHED_CLASSES.join(' '))
                .addClass(getPublishClass(published))
              recordingActions.find('.recording-update > i.hover')
                .removeClass(PUBLISHED_CLASSES.join(' '))
                .addClass(getPublishClass(!published))
              recordingActions.find('.recording-update')
                .attr('data-published', published)
                .attr('title', I18n[publishText+'_recording'])
              return recordingActions.html()
            return data
        }
      ]
    })
    options = {
      selector: '.delete-tooltip',
      container: 'body',
      placement: 'bottom',
      title: I18n.delete_recording
    };
    $('#recordings').tooltip(options);

  # Gets the current instance or creates a new one
  @getInstance: ->
    if _recordingsInstance && Recordings.initialized()
      return _recordingsInstance
    _recordingsInstance = new Recordings()
    return _recordingsInstance

  @initialize: ->
    Recordings.getInstance()

  @initialized: ->
    return $.fn.DataTable.isDataTable('#recordings') && _recordingsInstance

  draw: ->
    if !@isOwner()
      @table.api().columns(4).search('true')
    @table.api().columns.adjust().draw()

  # refresh the recordings from the server
  refresh: ->
    table_api = this.table.api()
    $.get "/rooms/"+Meeting.getInstance().getId()+"/recordings", (data) =>
      @setOwner(data.is_owner)
      if !@owner
        table_api.column(-1).visible(false)
      for recording in data.recordings
        totalMinutes = Math.round((new Date(recording.end_time) - new Date(recording.start_time)) / 1000 / 60)
        recording.duration = totalMinutes
      data.recordings.sort (a,b) ->
        return new Date(b.start_time) - new Date(a.start_time)
      table_api.clear()
      table_api.rows.add(data.recordings)
      @draw()

  # setup click handlers for the action buttons
  setupActionHandlers: ->
    table_api = this.table.api()
    this.table.on 'click', '.recording-update', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = $('.meeting-url').val()
      id = row.id
      published = btn.data('published')
      btn.prop('disabled', true)
      $.ajax({
        method: 'PATCH',
        url: url+'/recordings/'+id,
        data: {published: (!published).toString()}
      }).done((data) ->

      ).fail((data) ->
        btn.prop('disabled', false)
      )

    this.table.on 'click', '.recording-delete', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = $('.meeting-url').val()
      id = row.id
      btn.prop('disabled', true)
      $.ajax({
        method: 'DELETE',
        url: url+'/recordings/'+id
      }).done((data) ->

      ).fail((data) ->
        btn.prop('disabled', false)
      )

  isOwner: ->
    @owner

  setOwner: (owner) ->
    @owner = owner
