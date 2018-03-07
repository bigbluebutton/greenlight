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
  constructor: (@meetingId, @type, @userName, @adminId) ->

  # Gets the current instance or creates a new one
  @getInstance: ->
    if _meetingInstance
      return _meetingInstance
    meetingId = $(".page-wrapper").data('id')
    type = $("body").data('resource')
    name = $('.meeting-user-name').val()
    adminId = $(".page-wrapper").data('admin-id')
    _meetingInstance = new Meeting(meetingId, type, name, adminId)
    return _meetingInstance

  @clear: ->
    _meetingInstance = null

  @buildMeetingURL: (meetingId, type, adminId) ->
    fullId = ''
    if adminId
      fullId = encodeURIComponent(adminId) + '/' + encodeURIComponent(meetingId)
    else
      fullId = encodeURIComponent(meetingId)
    return @buildRootURL() + '/' + type + '/' + fullId

  @buildRootURL: ->
    url = location.protocol + '//' + location.hostname
    if location.port
      url += ':' + location.port
    if GreenLight.RELATIVE_ROOT
      url += GreenLight.RELATIVE_ROOT
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
    if !@userName
      showAlert(I18n.enter_name, 4000, 'danger')
      return false
    return $.get @getURL() + "/join?name=" + @userName, (data) =>
      # update name used to join meeting
      localStorage.setItem('lastJoinedName', @getUserName())

      if data.messageKey == 'ok'
        key = ''
        if @type == 'meetings'
          key = 'joinedMeetings'
        else if @type == 'rooms'
          key = 'joinedRooms-'+@adminId

        # update previously joined meetings/rooms on client
        try
          joinedMeetings = localStorage.getItem(key) || ''
          joinedMeetings = joinedMeetings.split(',')
          joinedMeetings = joinedMeetings.filter (item) => item != @meetingId.toString()
          if joinedMeetings.length >= 5
            joinedMeetings.splice(0, 1)
          joinedMeetings.push(@meetingId)
          localStorage.setItem(key, joinedMeetings.join(','))
        catch err
          localStorage.setItem(key, @meetingId)

  getMeetingId: ->
    return @meetingId

  setMeetingId: (id) ->
    @meetingId = id
    return this

  getAdminId: ->
    return @adminId

  setAdminId: (id) ->
    @adminId = id
    return this

  getType: ->
    return @type

  setType: (type) ->
    @type = type
    return this

  getURL: ->
    return Meeting.buildMeetingURL(@meetingId, @type, @adminId)

  getUserName: ->
    return @userName

  setUserName: (name) ->
    @userName = name
    return this

  getModJoined: ->
    return @modJoined

  setModJoined: (modJoined) ->
    @modJoined = modJoined
    return this

  getLTI: ->
    return @fromLTI

  setLTI: (fromLTI) ->
    @fromLTI = fromLTI
    return this

  getWaitingForMod: ->
    return @waitingForMod

  setWaitingForMod: (wMod) ->
    @waitingForMod = wMod
    return this
