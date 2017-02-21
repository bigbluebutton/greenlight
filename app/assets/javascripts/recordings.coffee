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
  # adding or removing a column will require updates to all subsequent column positions
  COLUMN = {
    DATE: 0,
    NAME: 1,
    PREVIEW: 2,
    DURATION: 3,
    PLAYBACK: 4,
    VISIBILITY: 5,
    LISTED: 6,
    ACTION: 7
  }

  constructor: ->
    # configure the datatable for recordings
    this.table = $('#recordings').dataTable({
      data: [],
      rowId: 'id',
      paging: false,
      dom: 't',
      info: false,
      order: [[ COLUMN.DATE, "desc" ]],
      language: {
        emptyTable: '<h3>'+I18n.no_recordings_yet+'</h3>',
        zeroRecords: '<h3>'+I18n.no_recordings+'</h3>'
      },
      columns: [
        { data: "start_time" },
        { data: "name", visible: $(".page-wrapper.rooms").data('main-room') },
        { data: "previews", orderable: false },
        { data: "duration", orderable: false },
        { data: "playbacks", orderable: false },
        { data: "published" },
        { data: "listed", visible: false },
        { data: "id", orderable: false }
      ],
      columnDefs: [
        {
          targets: COLUMN.DATE,
          render: (data, type, row) ->
            if type == 'display'
              date = new Date(data)
              title = date
                .toLocaleString($('html').attr('lang'),
                  {month: 'long', day: 'numeric', year: 'numeric',
                  hour12: 'true', hour: '2-digit', minute: '2-digit'})
              timeago = '<time datetime="'+date.toISOString()+'" data-time-ago="'+date.toISOString()+'">'+date.toISOString()+'</time>'
              return title+'<span class="timeago">('+timeago+')</span>'
            return data
        },
        {
          targets: COLUMN.PREVIEW,
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
          targets: COLUMN.PLAYBACK,
          render: (data, type, row) ->
            if type == 'display'
              str = ''
              if row.published
                if data.length == 1
                  str = '<a class="btn btn-default play-tooltip" href="'+data[0].url+'" target="_blank"><i class="fa fa-play-circle"></i></a>'
                else
                  for d in data
                    str += '<a href="'+d.url+'" target="_blank">'+d.type_i18n+'</a> '
              return str
            return data
        },
        {
          targets: COLUMN.VISIBILITY,
          render: (data, type, row) ->
            visibility = ['unpublished', 'unlisted', 'published']
            if row.published
              if row.listed
                state = visibility[2]
              else
                state = visibility[1]
            else
              state = visibility[0]
            if type == 'display'
              return I18n[state]
            return state
        },
        {
          targets: COLUMN.ACTION,
          render: (data, type, row) ->
            if type == 'display'
              roomName = Meeting.getInstance().getMeetingId()
              recordingActions = $('.hidden-elements').find('.recording-actions')
              classes = ['recording-unpublished', 'recording-unlisted', 'recording-published']
              if row.published
                if row.listed
                  cls = classes[2]
                else
                  cls = classes[1]
              else
                cls = classes[0]
              trigger = recordingActions.find('.recording-update-trigger')
              trigger.removeClass(classes.join(' '))
              trigger.addClass(cls)
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

    options.selector = '.visibility-tooltip'
    options.title = I18n.change_visibility
    $('#recordings').tooltip(options)

    options.selector = '.play-tooltip'
    options.title = I18n.play_recording
    $('#recordings').tooltip(options)

    $(document).one "turbolinks:before-cache", =>
      @getTable().api().clear().draw().destroy()

    # enable popovers
    # can't use trigger:'focus' because it doesn't work will with buttons inside
    # the popover
    options = {
      selector: '.has-popover',
      html: true,
      trigger: 'click',
      title: ->
        return $(this).data("popover-title");
      content: ->
        bodySelector = $(this).data("popover-body")
        return $(bodySelector).html()
    }
    $('#recordings').popover(options)

    # close popovers manually when clicking outside of them or in buttons
    # with [data-dismiss="popover"]
    # careful to hide only the open popover and not all of them, otherwise they won't reopen
    $('body').on 'click', (e) ->
      $('.has-popover').each ->
        if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover.in').has(e.target).length == 0
          if $(this).next(".popover.in").length > 0
            $(this).popover('hide')
    $(document).on 'click', '[data-dismiss="popover"]', (e) ->
      $('.has-popover').each ->
        if $(this).next(".popover.in").length > 0
          $(this).popover('hide')

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
      @table.api().columns(COLUMN.LISTED).search('true')
    @table.api().columns.adjust().draw()

  # refresh the recordings from the server
  refresh: ->
    table_api = this.table.api()
    $.get @getRecordingsURL(), (data) =>
      @setOwner(data.is_owner)
      if !@owner
        table_api.column(COLUMN.ACTION).visible(false)
        table_api.column(COLUMN.VISIBILITY).visible(false)
      for recording in data.recordings
        recording.duration = recording.length
      data.recordings.sort (a,b) ->
        return new Date(b.start_time) - new Date(a.start_time)
      table_api.clear()
      table_api.rows.add(data.recordings)
      @draw()

      if $(".page-wrapper.rooms").data('main-room')
        recording_names = data.recordings.map (r) ->
          return r.name
        output = {}
        for key in [0...recording_names.length]
          output[recording_names[key]] = recording_names[key]
        PreviousMeetings.uniqueAdd(value for key, value of output)


  # setup click handlers for the action buttons
  setupActionHandlers: ->
    table_api = this.table.api()
    recordingsObject = this

    @getTable().on 'click', '.recording-update', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = recordingsObject.getRecordingsURL()
      id = row.id

      published = btn.data('visibility') == "unlisted" ||
        btn.data('visibility') == "published"
      listed = btn.data('visibility') == "published"

      btn.prop('disabled', true)

      data = { published: published.toString() }
      data["meta_" + GreenLight.META_LISTED] = listed.toString();
      $.ajax({
        method: 'PATCH',
        url: url+'/'+id,
        data: data
      }).done((data) ->

      ).fail((data) ->
        btn.prop('disabled', false)
      )

    @getTable().on 'click', '.recording-delete', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = recordingsObject.getRecordingsURL()
      id = row.id
      btn.prop('disabled', true)
      $.ajax({
        method: 'DELETE',
        url: url+'/'+id
      }).done((data) ->

      ).fail((data) ->
        btn.prop('disabled', false)
      )

    @getTable().on 'draw.dt', (event) ->
      $('time[data-time-ago]').timeago();

  getTable: ->
    @table

  getRecordingsURL: ->
    if $(".page-wrapper.rooms").data('main-room')
      base_url = Meeting.buildRootURL()+'/'+$('body').data('resource')+'/'+Meeting.getInstance().getAdminId()
    else
      base_url = $('.meeting-url').val()
    base_url+'/recordings'

  isOwner: ->
    @owner

  setOwner: (owner) ->
    @owner = owner
