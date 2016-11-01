$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var getRoomName = function() {
  return $(".page-wrapper.rooms").data('room');
}

var PUBLISHED_CLASSES = ['fa-eye-slash', 'fa-eye']

var getPublishClass = function(published) {
  return PUBLISHED_CLASSES[+published];
}

var meetingInstance = null;
class Meeting {
  constructor(url, name) {
    this.url = url;
    this.name = name;
  }

  static getInstance() {
    if (meetingInstance) {
      return meetingInstance;
    }
    var url = $('.meeting-url').val();
    var name = $('.meeting-user-name').val();
    meetingInstance = new Meeting(url, name);
    return meetingInstance;
  }

  getjoinMeetingURL() {
    return $.get(this.url + "/join?name=" + this.name, function() {
    });
  };

  setURL(url) {
    this.url = url;
  }
  setName(name) {
    this.name = name;
  }
  setModJoined(modJoined) {
    this.modJoined = modJoined;
  }
  getModJoined() {
    return this.modJoined;
  }
  setWaitingForMod(wMod) {
    this.waitingForMod = wMod;
  }
  getWaitingForMod() {
    return this.waitingForMod;
  }
}

var loopJoin = function() {
  var jqxhr = Meeting.getInstance().getjoinMeetingURL();
  jqxhr.done(function(data) {
    if (data.messageKey === 'wait_for_moderator') {
      setTimeout(loopJoin, 5000);
    } else {
      $(location).attr("href", data.response.join_url);
    }
  });
  jqxhr.fail(function(xhr, status, error) {
    console.info("meeting join failed");
  });
}
