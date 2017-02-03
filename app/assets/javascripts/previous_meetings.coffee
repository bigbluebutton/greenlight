class @PreviousMeetings
  @init: (type)->
    $('.center-panel-wrapper').on 'click', '.fill-meeting-name', (event, msg) ->
      name = $(this).text()
      $('input.meeting-name').val(name).trigger('input')

    $('ul.previously-joined').empty()
    joinedMeetings = localStorage.getItem(type)
    if joinedMeetings && joinedMeetings.length > 0
      joinedMeetings = joinedMeetings.split(',')

      for m in joinedMeetings by -1
        $('ul.previously-joined').append('<li><a class="fill-meeting-name">'+m+'</a></li>')

      $('.center-panel-wrapper .previously-joined-wrapper').removeClass('hidden')
