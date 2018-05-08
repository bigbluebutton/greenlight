$(document).on("turbolinks:load", function() {

  var action = $("body").data('action');
  var controller = $("body").data('controller');

  // If the user is on the waiting screen.
  if (controller == 'meetings' && action == 'wait') {

    setTimeout(refresh, 10000);
  }
});

// Send a request to the meeting wait endpoint.
// This checks if the meeting is running on the
// server and will auto join the user if it is.
var refresh = function() {
  $.ajax({
    url: window.location.pathname,
    type: 'POST',
    data: {
      unauthenticated_join_name: $('#unauthenticated_join_name_').val()
    },
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  });

  setTimeout(refresh, 10000);
}