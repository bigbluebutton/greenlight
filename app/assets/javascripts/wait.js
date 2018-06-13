// Handle client request to join when meeting starts.

$(document).on("turbolinks:load", function(){
  var controller = $("body").data('controller');
  var action = $("body").data('action');

  if(controller == "rooms" && action == "join"){
    App.waiting = App.cable.subscriptions.create({
      channel: "WaitingChannel",
      uid: $(".background").attr("room")
    }, {
      received: function(data){
        if(data.action = "started"){ request_to_join_meeting(); }
      }
    });
  }
});

var join_attempts = 0;

var request_to_join_meeting = function(){
  $.ajax({
    url: window.location.pathname,
    type: 'POST',
    data: {
      join_name: $(".background").attr("join-name")
    },
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    error: function(){
      // The meeting is still booting (going slowly), retry shortly.
      if(join_attempts < 4){ setTimeout(request_to_join_meeting, 10000); }
      join_attempts++;
    }
  });
}
