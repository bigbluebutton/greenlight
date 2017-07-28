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
  COLUMNS = [
    'DATE',
    'NAME',
    'PREVIEW',
    'DURATION',
    'PARTICIPANTS',
    'PLAYBACK',
    'VISIBILITY',
    'LISTED',
    'ACTION'
  ]
  COLUMN = {}
  i = 0
  for c in COLUMNS
    COLUMN[c] = i++

  constructor: ->
    recordingsObject = this

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
        { data: "duration" },
        { data: "participants" },
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

    options.selector = '.youtube-tooltip'
    options.title = I18n.upload_youtube
    $('#recordings').tooltip(options)

    options.selector = '.upload-tooltip'
    options.title = I18n.share
    $('#recordings').tooltip(options)

    options.selector = '.mail-tooltip'
    options.title = I18n.mail_recording
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
    selectedUpload = null
    canUpload = false

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
        btn.prop('disabled', false)
      ).fail((xhr, text) ->
        btn.prop('disabled', false)
      )

    @getTable().on 'click', '.recording-delete', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr'))
      url = recordingsObject.getRecordingsURL()
      id = row.data().id
      btn.prop('disabled', true)
      $.ajax({
        method: 'DELETE',
        url: url+'/'+id
      }).done((data) ->
        btn.prop('disabled', false)
      ).fail((xhr, text) ->
        btn.prop('disabled', false)
        if xhr.status == 404
          row.remove();
          recordingsObject.draw()
          showAlert(I18n.recording_deleted, 4000);
      )

    @getTable().on 'click', '.upload-button', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = recordingsObject.getRecordingsURL()
      id = row.id

      title = $('#video-title').val()
      privacy_status = $('input[name=privacy_status]:checked').val()

      if title == ''
        title = row.name

      $.ajax({
        method: 'POST',
        url: url+'/'+id
        data: {video_title: title, privacy_status: privacy_status}
        success: (data) ->

          if data['url'] != null
            window.location.href = data['url']
          else
            cloud = selectedUpload.find('.cloud-blue')
            check = selectedUpload.find('.green-check')
            spinner = selectedUpload.find('.load-spinner')

            showAlert(I18n.successful_upload, 4000);

            spinner.hide()
            check.show()

            setTimeout ( ->
              cloud.show()
              check.hide()
            ), 2500
      })

      selectedUpload.find('.cloud-blue').hide()
      selectedUpload.find('.load-spinner').show()

    @getTable().on 'click', '.mail-recording', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      url = recordingsObject.getRecordingsURL()
      id = row.id

      # Take the username from the header.
      username = $('#title-header').text().replace('Welcome ', '').trim()

      recording_url = row.playbacks[0].url
      webcams_url = getHostName(recording_url) + '/presentation/' + id + '/video/webcams.webm'
      subject = username + I18n.recording_mail_subject
      body = I18n.recording_mail_body + "\n\n" + recording_url + "\n\n" + I18n.email_footer_1 + "\n" + I18n.email_footer_2

      mailto = "mailto:?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
      window.open(mailto);

    @getTable().on 'click', '.youtube-upload', (event) ->
      row = table_api.row($(this).closest('tr')).data()
      $('#video-title').attr('value', row.name)

    @getTable().on 'click', '.cloud-upload', (event) ->
      btn = $(this)
      row = table_api.row($(this).closest('tr')).data()
      id = row.id

      selectedUpload = $(this)

      # Determine if the recording can be uploaded to Youtube.
      $.ajax({
        method: 'POST',
        data: {'rec_id': id},
        async: false,
        url: recordingsObject.getRecordingsURL() + '/can_upload'
      }).success((res_data) ->
        canUpload = res_data['uploadable']
      )
      
      youtube_button = $('.share-popover').find('.youtube-upload')
      
      attr = $(this).attr('data-popover-body');
      
      # Check if the cloud button has a popover body.
      if (typeof attr == typeof undefined || attr == false)
        switch canUpload
          # We can upload the recording.
          when 'true'
            youtube_button.attr('title', I18n.upload_youtube)
            youtube_button.removeClass('disabled-button')
            youtube_button.addClass('has-popover')
            youtube_button.show()
          # Can't upload because uploading is disabled.
          when 'uploading_disabled'
            youtube_button.hide()
          # Can't upload because account is not authenticated with Google.
          when 'invalid_provider'
            youtube_button.attr('title', I18n.invalid_provider)
            youtube_button.addClass('disabled-button')
            youtube_button.removeClass('has-popover')
            youtube_button.show()
          # Can't upload because recording does not contain video.
          else
            youtube_button.attr('title', I18n.no_video)
            youtube_button.addClass('disabled-button')
            youtube_button.removeClass('has-popover')
            youtube_button.show()

        $(this).attr('data-popover-body', '.share-popover')
        $(this).popover('show')
      else
        $(this).popover('hide')
        $(this).removeAttr('data-popover-body')
        

    @getTable().on 'draw.dt', (event) ->
      $('time[data-time-ago]').timeago();

  getTable: ->
    @table

  getHostName = (url) ->
    parser = document.createElement('a');
    parser.href = url;
    parser.origin;

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
