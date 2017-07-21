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

// Updates the previous meetings section.
var updatePreviousMeetings = function(){
  $("ul.previously-joined li").each(function(idx, li) {
    var previous_meeting = $(li);
    if(Object.keys(MEETINGS).indexOf(previous_meeting.text()) > -1){
      previous_meeting.remove()
    }
  });
}

// Adds a user to a meeting.
var addUser = function(data){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'].push(data['user'])
  } else {
    MEETINGS[data['meeting']]['participants'].push(data['user'])
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

// Removes a user from a meeting.
var removeUser = function(data){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'].splice(MEETINGS[data['meeting']]['moderators'].indexOf(data['user']), 1);
  } else {
    MEETINGS[data['meeting']]['participants'].splice(MEETINGS[data['meeting']]['participants'].indexOf(data['user']), 1);
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

// Updates the display text for an active meeting.
var updateMeetingText = function(m){
  // If a meeting has a moderators property, it is running.
  var body;
  if(m.hasOwnProperty('moderators')){
    var list;
    if(m['moderators'].length + m['participants'].length == 0){
      list = '(empty)'
    } else {
      list = m['moderators'].join('(mod), ') + (m['moderators'].length > 0 ? '(mod)' : '') +
        (m['participants'].length > 0 && m['moderators'].length != 0 ? ', ' : '') + m['participants'].join(', ')
    }
    body = '<a>' + m['name'] + '</a><i>: ' + list + '</i>'
  // Otherwise it hasn't started (users waiting the join).
  } else {
    body = '<a>' + m['name'] + '</a><i> (not yet started): ' + 
                  m['users'].join(', ') + '</i>'
  }

  // If the item doesn't exist, add it and set up join meeting event.
  if($("li[id='" +  m['name'].replace(' ', '_') + "']").length == 0){
    var meeting_item = $("<li>" + body + "</li>")
    meeting_item.attr('id', m['name'].replace(' ', '_'))
    $('.actives').append(meeting_item);

    // Set up join on click.
    meeting_item.click(function(){
      joinMeeting(m['name']);
    });
  // Otherwise, just change the body.
  } else {
    $("li[id='" +  m['name'].replace(' ', '_') + "']").html(body)
  }
}

// Initially populates the active meetings when the page loads using the API.
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
      
      var attendees;
      if(meetings[i]['attendees']['attendee'] instanceof Array){
        attendees = meetings[i]['attendees']['attendee']
      } else {
        attendees = [meetings[i]['attendees']['attendee']]
      }
      
      var participants = []
      var moderators = []
      
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
  });
}

// Checks if a meeting has been prveiously joined by the user.
var isPreviouslyJoined = function(meeting){
  var joinedMeetings = localStorage.getItem('joinedRooms-' + $('body').data('current-user'));
  if (joinedMeetings == '' || joinedMeetings == null){ return false; }
  return joinedMeetings.split(',').indexOf(meeting) >= 0
}

// Removes an active meeting.
var removeActiveMeeting = function(meeting){
  if(meeting){ $("li[id='" +  meeting['name'].replace(' ', '_') + "']").remove() }
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
    // Ensure actives is empty.
    $('.actives').empty();

    if(!App.messages){
      // Setup actioncable.
      App.messages = App.cable.subscriptions.create('RefreshMeetingsChannel', {
        received: function(data) {
          console.log('Recieved ' + data['method'] + ' action for ' + data['meeting'] + ' with room id ' + data['room'] + '.')
          if(data['room'] == $('body').data('current-user')){
            // Handle webhook event.
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
    // Short delay to hide the previous meetings population.
    setTimeout(initialPopulate, LOADING_DELAY);
  }
});
