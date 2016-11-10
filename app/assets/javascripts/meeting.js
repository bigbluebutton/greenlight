// Meeting class

var _meetingInstance = null;

class Meeting {
  constructor(id, url, name) {
    this.id = id;
    this.url = url;
    this.name = name;
  }

  // Gets the current instance or creates a new one
  static getInstance() {
    if (_meetingInstance) {
      return _meetingInstance;
    }
    var id = $(".page-wrapper.rooms").data('room');
    var url = Meeting.buildURL();
    var name = $('.meeting-user-name').val();
    _meetingInstance = new Meeting(id, url, name);
    return _meetingInstance;
  }

  static buildURL() {
    return location.protocol +
      '//' +
      location.hostname +
      '/rooms/' +
      $('.rooms').data('room');
  }

  // Sends the end meeting request
  // Returns a response object
  endMeeting() {
    return $.ajax({
      url: this.url + "/end",
      type: 'DELETE'
    });
  }

  // Makes a call to get the join meeting url
  // Returns a response object
  //    The response object contains the URL to join the meeting
  getJoinMeetingResponse() {
    return $.get(this.url + "/join?name=" + this.name, function() {
    });
  };

  getId() {
    return this.id;
  }

  getURL() {
    return this.url;
  }

  getName() {
    return this.name;
  }

  setName(name) {
    this.name = name;
  }

  getModJoined() {
    return this.modJoined;
  }

  setModJoined(modJoined) {
    this.modJoined = modJoined;
  }

  getWaitingForMod() {
    return this.waitingForMod;
  }

  setWaitingForMod(wMod) {
    this.waitingForMod = wMod;
  }
}
