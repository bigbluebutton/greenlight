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
  constructor: (@id, @url, @name) ->

  # Gets the current instance or creates a new one
  @getInstance: ->
    if _meetingInstance
      return _meetingInstance
    id = $(".page-wrapper").data('id')
    url = @buildMeetingURL()
    name = $('.meeting-user-name').val()
    _meetingInstance = new Meeting(id, url, name)
    return _meetingInstance

  @clear: ->
    _meetingInstance = null

  @buildMeetingURL: (id) ->
    if (resource = location.pathname.split('/')[1]) != 'rooms'
      resource = 'meetings'
    id ||= $(".page-wrapper").data('id')
    return @buildFullDomainURL() + '/' + resource + '/' + id

  @buildFullDomainURL: ->
    url = location.protocol + '//' + location.hostname
    if location.port
      url += ':' + location.port
    return url

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

  setId: (id) ->
    @id = id

  getURL: ->
    return @url

  setURL: (url) ->
    @url = url

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
