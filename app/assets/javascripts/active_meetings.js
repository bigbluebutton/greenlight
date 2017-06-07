
MEETINGS = {}

// Only need to register for logged in users.
if($('body').data('current-user')){
  App.messages = App.cable.subscriptions.create('RefreshMeetingsChannel', {
    received: function(data) {
      console.log(data)
      if(isPreviouslyJoined(data['meeting'])){
        if(data['method'] == 'create'){

          // Create an empty meeting.
          MEETINGS[data['meeting']] = {'name': data['meeting'],
                                      'participants': 0,
                                      'moderators': 0}

          renderActiveMeeting(MEETINGS[data['meeting']])
        } else if(data['method'] == 'destroy'){
          removeActiveMeeting(MEETINGS[data['meeting']])
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

handleUser = function(data, n){
  if(data['role'] == 'MODERATOR'){
    MEETINGS[data['meeting']]['moderators'] += n
  } else {
    MEETINGS[data['meeting']]['participants'] += n
  }
  updateMeetingText(MEETINGS[data['meeting']])
}

updateMeetingText = function(meeting){
  $('#' + meeting['name']).html('<a>' + meeting['name'] + '</a> <i>(' +
          meeting['participants'] + ((meeting['participants'] == 1) ? ' user, ' : ' users, ') +
          meeting['moderators'] + ((meeting['moderators'] == 1) ? ' mod)' : ' mods)'))
}

initialPopulate = function(){
  $.get(window.location.origin + '/rooms/' + $('body').data('current-user') + '/request', function(data){
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
        // remove it.
      }
    }
  });
}

isPreviouslyJoined = function(meeting){
  joinedMeetings = localStorage.getItem('joinedRooms-' + $('body').data('current-user')).split(',');
  return joinedMeetings.indexOf(meeting) >= 0
}

renderActiveMeeting = function(m){
  var meeting_item = $('<li id = ' + m['name'] + '><a>' + m['name'] + '</a>' +
          ' <i>(' + m['participants'] + ' users, ' + m['moderators'] + ' mods)</i>' + '</li>')
  $('.actives').append(meeting_item);

  // Set up join on click.
  meeting_item.click(function(){
    joinMeeting(name);
  });
}

removeActiveMeeting = function(meeting){
  $('#' + meeting['name']).remove()
  //$(".actives:contains('" + meeting['name'] + "')").remove()
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

if($('body').data('current-user')){ console.log('Populating active meetings.'); initialPopulate() }
