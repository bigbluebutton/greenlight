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

# Previous Meetings class

class @PreviousMeetings
  MAX_MEETINGS = 5

  # initializes and populates previous meetings list with entries from localStorage
  @init: (type) ->
    $('.center-panel-wrapper').off 'click', '.fill-meeting-name'
    $('.center-panel-wrapper').on 'click', '.fill-meeting-name', (event, msg) ->
      name = $(this).text()
      $('input.meeting-name').val(name).trigger('input')

    $('ul.previously-joined').empty()
    joinedMeetings = localStorage.getItem(type)
    if joinedMeetings && joinedMeetings.length > 0
      joinedMeetings = joinedMeetings.split(',')
      PreviousMeetings.append(joinedMeetings.reverse())

  # adds to previous meetings list if its unique
  @uniqueAdd: (names) ->
    meetings = $('ul.previously-joined > li').toArray().map( (li) ->
      return li.innerText
    )
    index = meetings.indexOf('')
    if index > 1
      meetings.splice(index, 1)
    if Array.isArray(names)
      names = names.filter( (value) ->
        return $.inArray(value, meetings) == -1
      )
      PreviousMeetings.append(names)

  @append: (meeting_names) ->
    for m in meeting_names
      if $('ul.previously-joined > li').length > MAX_MEETINGS
        break
      $('ul.previously-joined').append('<li><a class="fill-meeting-name">'+m+'</a></li>')

    $('.center-panel-wrapper .previously-joined-wrapper').removeClass('hidden')
