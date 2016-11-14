# Meeting class

_meetingInstance = null

class @Meeting
  constructor: (@id, @url, @name) ->

  # Gets the current instance or creates a new one
  @getInstance: ->
    if _meetingInstance
      return _meetingInstance
    id = $(".page-wrapper.rooms").data('room')
    url = @buildURL()
    name = $('.meeting-user-name').val()
    _meetingInstance = new Meeting(id, url, name)
    return _meetingInstance

  @buildURL: ->
    return location.protocol +
      '//' +
      location.hostname +
      '/rooms/' +
      $('.rooms').data('room')

  # Sends the end meeting request
  # Returns a response object
  endMeeting: ->
    return $.ajax({
      url: @url + "/end",
      type: 'DELETE'
    })

  # Makes a call to get the join meeting url
  # Returns a response object
  #    The response object contains the URL to join the meeting
  getJoinMeetingResponse: ->
    return $.get @url + "/join?name=" + @name, ->


  getId: ->
    return @id

  getURL: ->
    return @url

  getName: ->
    return @name

  setName: (name) ->
    @name = name

  getModJoined: ->
    return @modJoined

  setModJoined: (modJoined) ->
    @modJoined = modJoined

  getWaitingForMod: ->
    return @waitingForMod

  setWaitingForMod: (wMod) ->
    @waitingForMod = wMod
