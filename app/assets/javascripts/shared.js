$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var PUBLISHED_CLASSES = ['fa-eye-slash', 'fa-eye']

var getPublishClass = function(published) {
  return PUBLISHED_CLASSES[+published];
}

var loopJoin = function() {
  var jqxhr = Meeting.getInstance().getJoinMeetingResponse();
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

var showAlert = function(html, timeout_delay) {
  if (!html) {
    return;
  }

  $('.alert-template .alert-message').html(html);
  $('#alerts').html($('.alert-template').html());

  if (timeout_delay) {
    setTimeout(function() {
      $('#alerts > .alert').alert('close');
    }, timeout_delay);
  }
}

var displayRoomURL = function() {
  $('.meeting-url').val(Meeting.getInstance().getURL());
}
