// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

// Handles live updating and initial population of the previous meetings and active meetings lists on
// the landing page using custom Actioncable events.

MEETINGS = {}
LOADING_DELAY = 1250 // milliseconds.

updatePreviousMeetings = function(){
  $("ul.previously-joined li").each(function(idx, li) {
    previous_meeting = $(li);
    if(Object.keys(MEETINGS).indexOf(previous_meeting.text()) > -1){
      previous_meeting.remove()
    }
  });
}

handleUser = function(data, n){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'] += n
  } else {
    MEETINGS[data['meeting']]['participants'] += n
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

updateMeetingText = function(meeting){
  $('#' + meeting['name'].replace(' ', '_')).html('<a>' + meeting['name'] + '</a> <i>(' +
          meeting['participants'] + ((meeting['participants'] == 1) ? ' user, ' : ' users, ') +
          meeting['moderators'] + ((meeting['moderators'] == 1) ? ' mod)' : ' mods)'))
}

initialPopulate = function(){
  if (window.location.href.includes('preferences')) { return; }
  $.get((window.location.href + '/request').replace('#', ''), function(data){
    meetings = data['meetings']
    for(var i = 0; i < meetings.length; i++){
      name = meetings[i]['meetingName']
      participants = parseInt(meetings[i]['participantCount'])
      moderators = parseInt(meetings[i]['moderatorCount'])
      // Create meeting.
      MEETINGS[name] = {'name': name,
                        'participants': participants - moderators,
                        'moderators': moderators}
      if(isPreviouslyJoined(name)){
        renderActiveMeeting(MEETINGS[name])
      }
    }
  }).done(function(){
    // Remove from previous meetings if they are active.
    updatePreviousMeetings();
    $('.hidden-list').show();
    $('.fa-spinner').hide();
  }).error(function(){
    console.log('Not on a page to load meetings.')
    return true;
  });
}

isPreviouslyJoined = function(meeting){
  joinedMeetings = localStorage.getItem('joinedRooms-' + $('body').data('current-user')).split(',');
  return joinedMeetings.indexOf(meeting) >= 0
}

renderActiveMeeting = function(m){
  var meeting_item = $('<li id = ' + m['name'].replace(' ', '_') + '><a>' + m['name'] + '</a>' +
          ' <i>(' + m['participants'] + ((m['participants'] == 1) ? ' user, ' : ' users, ') +
          m['moderators'] + ((m['moderators'] == 1) ? ' mod)' : ' mods)') + '</i>' + '</li>')
  $('.actives').append(meeting_item);

  // Set up join on click.
  meeting_item.click(function(){
    joinMeeting(name);
  });
}

removeActiveMeeting = function(meeting){
  $('#' + meeting['name'].replace(' ', '_')).remove()
}

// Directly join a meeting from active meetings.
joinMeeting = function(meeting_name){
  var name = $('.meeting-user-name').val();
  Meeting.getInstance().setUserName(localStorage.getItem('lastJoinedName'));
  Meeting.getInstance().setMeetingId(meeting_name);

  // a user name is set, join the user into the session
  if (name !== undefined && name !== null) {
    var jqxhr = Meeting.getInstance().getJoinMeetingResponse();
    if (jqxhr) {
      jqxhr.done(function(data) {
        if (data.messageKey === 'wait_for_moderator') {
          waitForModerator(Meeting.getInstance().getURL());
        } else {
          $(location).attr("href", data.response.join_url);
        }
      });
      jqxhr.fail(function(xhr, status, error) {
        console.info("meeting join failed");
      });
    } else {
      $('.meeting-user-name').parent().addClass('has-error');
    }

  // if not user name was set it means we must ask for a name
  } else {
    $(location).attr("href", Meeting.getInstance().getURL());
  }
}

// Only need to register for logged in users.
$(document).on('turbolinks:load', function(){
  if($('body').data('current-user')){

    MEETINGS = {}
    $('.actives').empty();

    if(!App.messages){
      App.messages = App.cable.subscriptions.create('RefreshMeetingsChannel', {
        received: function(data) {
          console.log('Recieved ' + data['method'] + ' action for ' + data['meeting'] + '.')
          if(isPreviouslyJoined(data['meeting'])){
            if(data['method'] == 'create'){
              // Create an empty meeting.
              MEETINGS[data['meeting']] = {'name': data['meeting'],
                                          'participants': 0,
                                          'moderators': 0}

              renderActiveMeeting(MEETINGS[data['meeting']])
              updatePreviousMeetings();
            } else if(data['method'] == 'destroy'){
              removeActiveMeeting(MEETINGS[data['meeting']])
              PreviousMeetings.append([data['meeting']])
              delete MEETINGS[data['meeting']]
            } else if(data['method'] == 'join'){
              handleUser(data, 1)
              updateMeetingText(MEETINGS[data['meeting']])
            } else if(data['method'] == 'leave'){
              handleUser(data, -1)
            }
          }
        }
      });
    }

    console.log('Populating active meetings.');
    setTimeout(initialPopulate, LOADING_DELAY);
  }
});
