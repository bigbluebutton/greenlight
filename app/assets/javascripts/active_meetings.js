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

var MEETINGS = {}
var WAITING = {}
var LOADING_DELAY = 1750 // milliseconds.

var updatePreviousMeetings = function(){
  $("ul.previously-joined li").each(function(idx, li) {
    previous_meeting = $(li);
    if(Object.keys(MEETINGS).indexOf(previous_meeting.text()) > -1){
      previous_meeting.remove()
    }
  });
}

var addUser = function(data){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'].push(data['user'])
  } else {
    MEETINGS[data['meeting']]['participants'].push(data['user'])
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

var removeUser = function(data){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'].splice(MEETINGS[data['meeting']]['moderators'].indexOf(data['user']), 1);
  } else {
    MEETINGS[data['meeting']]['participants'].splice(MEETINGS[data['meeting']]['participants'].indexOf(data['user']), 1);
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

var updateMeetingText = function(m){
  if(m.hasOwnProperty('moderators')){
    var list;
    if(m['moderators'].length + m['participants'].length == 0){
      list = '(empty)'
    } else {
      list = m['moderators'].join('(mod), ') + (m['moderators'].length > 0 ? '(mod)' : '') +
      (m['participants'].length > 0 && m['moderators'].length != 0 ? ', ' : '') + m['participants'].join(', ')
    }
    var body = '<a>' + m['name'] + '</a><i>: ' + list + '</i>'
  } else {
    var body = '<a>' + m['name'] + '</a><i> (not yet started): ' + 
                m['users'].join(', ') + '</i>'
  }

  if($('#' + m['name'].replace(' ', '_')).length == 0){
    var meeting_item = $('<li id = ' + m['name'].replace(' ', '_') + '>' + body + '</li>')
    $('.actives').append(meeting_item);

    // Set up join on click.
    meeting_item.click(function(){
      joinMeeting(m['name']);
    });
  } else {
    $('#' + m['name'].replace(' ', '_')).html(body)
  }
}

var initialPopulate = function(){
  // Only populate on room resources.
  var chopped = window.location.href.split('/')
  if (!window.location.href.includes('rooms') || chopped[chopped.length - 2] == $('body').data('current-user')) { return; }
  $.get((window.location.href + '/request').replace('#', ''), function(data){
    var meetings = data['active']['meetings']
    var waiting = data['waiting']
    
    jQuery.each(waiting[$('body').data('current-user')], function(name, users){
      WAITING[name] = {'name': name,
                       'users': users}
      updateMeetingText(WAITING[name])
    });
    
    for(var i = 0; i < meetings.length; i++){
      // Make sure the meeting actually belongs to the current user.
      if(meetings[i]['metadata']['room-id'] != $('body').data('current-user')) { continue; }
      var name = meetings[i]['meetingName']
      
      var participants = []
      var moderators = []
      
      var attendees;
      if(meetings[i]['attendees']['attendee'] instanceof Array){
        attendees = meetings[i]['attendees']['attendee']
      } else {
        attendees = [meetings[i]['attendees']['attendee']]
      }
      
      jQuery.each(attendees, function(i, attendee){
        // The API doesn't return a empty array when empty, just undefined.
        if(attendee != undefined){
          if(attendee['role'] == "MODERATOR"){
            moderators.push(attendee['fullName'])
          } else {
            participants.push(attendee['fullName'])
          }
        }
      });
      
      // Create meeting.
      MEETINGS[name] = {'name': name,
                        'participants': participants,
                        'moderators': moderators}
                        
      if(isPreviouslyJoined(name)){
        updateMeetingText(MEETINGS[name])
      }
    }
    
  }).done(function(){
    // Remove from previous meetings if they are active.
    updatePreviousMeetings();
    $('.hidden-list').show();
    $('.active-spinner').hide();
  }).error(function(){
    console.log('Not on a page to load meetings.')
    return true;
  });
}

var isPreviouslyJoined = function(meeting){
  joinedMeetings = localStorage.getItem('joinedRooms-' + $('body').data('current-user'));
  if (joinedMeetings == '' || joinedMeetings == null){ return false; }
  return joinedMeetings.split(',').indexOf(meeting) >= 0
}

var removeActiveMeeting = function(meeting){
  if(meeting){
    $('#' + meeting['name'].replace(' ', '_')).remove()
  }
}

// Directly join a meeting from active meetings.
var joinMeeting = function(meeting_name){
  if (meeting_name == undefined || meeting_name == null) { return; }
  Meeting.getInstance().setUserName(localStorage.getItem('lastJoinedName'));
  Meeting.getInstance().setMeetingId(meeting_name);

  var jqxhr = Meeting.getInstance().getJoinMeetingResponse();
  if (jqxhr) {
    jqxhr.done(function(data) {
      if (data.messageKey === 'wait_for_moderator') {
        waitForModerator(Meeting.getInstance().getURL());
      } else {
        $(location).attr("href", data.response.join_url);
      }
    });
    jqxhr.fail(function() {
      console.info("meeting join failed");
    });
  } else {
    $('.meeting-user-name').parent().addClass('has-error');
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
          console.log('Recieved ' + data['method'] + ' action for ' + data['meeting'] + ' with room id ' + data['room'] + '.')
          if(isPreviouslyJoined(data['meeting']) && data['room'] == $('body').data('current-user')){
            if(data['method'] == 'create'){
              // Create an empty meeting.
              MEETINGS[data['meeting']] = {'name': data['meeting'],
                                          'participants': [],
                                          'moderators': []}
              updateMeetingText(MEETINGS[data['meeting']])
              updatePreviousMeetings();
              if (WAITING.hasOwnProperty(data['meeting'])){ delete WAITING[data['meeting']]; }
            } else if(data['method'] == 'destroy'){
              removeActiveMeeting(MEETINGS[data['meeting']])
              PreviousMeetings.uniqueAdd([data['meeting']])
              delete MEETINGS[data['meeting']]
            } else if(data['method'] == 'join'){
              addUser(data)
            } else if(data['method'] == 'leave'){
              removeUser(data)
            } else if(data['method'] == 'waiting'){
              // Handle waiting meeting.
              if(WAITING.hasOwnProperty(data['meeting'])){
                WAITING[data['meeting']]['users'].push(data['user'])
                updateMeetingText(WAITING[data['meeting']])
              } else {
                WAITING[data['meeting']] = {'name': data['meeting'],
                                            'users': [data['user']]}
                updateMeetingText(WAITING[data['meeting']])
              }
            } else if((data['method'] == 'no_longer_waiting') && (WAITING.hasOwnProperty(data['meeting']))){
                WAITING[data['meeting']]['users'].splice(WAITING[data['meeting']]['users'].indexOf(data['user']), 1)
                updateMeetingText(WAITING[data['meeting']])
                if(WAITING[data['meeting']]['users'].length == 0){
                  removeActiveMeeting(WAITING[data['meeting']])
                  delete WAITING[data['meeting']]
                }
            }
          }
        }
      });
    }

    console.log('Populating active meetings.');
    setTimeout(initialPopulate, LOADING_DELAY);
  }
});
