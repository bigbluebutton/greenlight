# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

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
        emptyTable: '<h3>'+I18n.no_recordings_yet+'</h3>',
        zeroRecords: '<h3>'+I18n.no_recordings+'</h3>'
      },
      columns: [
        { data: "start_time" },
        { data: "previews", orderable: false },
        { data: "duration", orderable: false },
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
                  str += '<img height="50" width="50" class="img-thumbnail" src="'+d.url+'" alt="'+d.alt+'"></img><img class="img-thumbnail large" src="'+d.url+'"></img>'
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
      placement: 'bottom',
      title: I18n.delete_recording
    };
    $('#recordings').tooltip(options)

    $(document).one "turbolinks:before-cache", =>
      @getTable().api().clear().draw().destroy()

    # enable popovers
    options = {
      selector: '.has-popover',
      html: true,
      trigger: 'focus',
      title: ->
        return I18n.are_you_sure;
      content: ->
        return $(".delete-popover-body").html()
    }
    $('#recordings').popover(options)

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
        recording.duration = recording.length
      data.recordings.sort (a,b) ->
        return new Date(b.start_time) - new Date(a.start_time)
      table_api.clear()
      table_api.rows.add(data.recordings)
      @draw()

  # setup click handlers for the action buttons
  setupActionHandlers: ->
    table_api = this.table.api()
    @getTable().on 'click', '.recording-update', (event) ->
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

  getTable: ->
    @table

  isOwner: ->
    @owner

  setOwner: (owner) ->
    @owner = owner
