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

# Meeting class

_meetingInstance = null

class @Meeting
  constructor: (@id, @type, @name) ->

  # Gets the current instance or creates a new one
  @getInstance: ->
    if _meetingInstance
      return _meetingInstance
    id = $(".page-wrapper").data('id')
    if (type = location.pathname.split('/')[1]) != 'rooms'
      type = 'meetings'
    name = $('.meeting-user-name').val()
    _meetingInstance = new Meeting(id, type, name)
    return _meetingInstance

  @clear: ->
    _meetingInstance = null

  @buildMeetingURL: (id, type) ->
    return @buildFullDomainURL() + '/' + type + '/' + id

  @buildFullDomainURL: ->
    url = location.protocol + '//' + location.hostname
    if location.port
      url += ':' + location.port
    return url

  # Sends the end meeting request
  # Returns a response object
  endMeeting: ->
    return $.ajax({
      url: @getURL() + "/end",
      type: 'DELETE'
    })

  # Makes a call to get the join meeting url
  # Returns a response object
  #    The response object contains the URL to join the meeting
  getJoinMeetingResponse: ->
    return $.get @getURL() + "/join?name=" + @name, (data) =>
      if data.messageKey == 'ok' && @type == 'meetings'
        try
          joinedMeetings = localStorage.getItem('joinedMeetings') || ''
          joinedMeetings = joinedMeetings.split(',')
          joinedMeetings = joinedMeetings.filter (item) => item != @id.toString()
          if joinedMeetings.length >= 5
            joinedMeetings.splice(0, 1)
          joinedMeetings.push(@id)
          localStorage.setItem('joinedMeetings', joinedMeetings.join(','))
        catch err
          localStorage.setItem('joinedMeetings', @id)

  getId: ->
    return @id

  setId: (id) ->
    @id = id
    return this

  getType: ->
    return @type

  setType: (type) ->
    @type = type
    return this

  getURL: ->
    return Meeting.buildMeetingURL(@id, @type)

  getName: ->
    return @name

  setName: (name) ->
    @name = name
    return this

  getModJoined: ->
    return @modJoined

  setModJoined: (modJoined) ->
    @modJoined = modJoined
    return this

  getWaitingForMod: ->
    return @waitingForMod

  setWaitingForMod: (wMod) ->
    @waitingForMod = wMod
    return this
