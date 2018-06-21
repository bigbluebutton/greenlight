// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  var protocol = (window.location.protocol === "https:" ? "wss://" : "ws://");
  var host = window.GreenLight.WEBSOCKET_HOST || window.location.host + window.GreenLight.RELATIVE_ROOT;
  var url = protocol + host + '/cable';

  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer(url);
}).call(this);
