import consumer from './consumer';

export default function subscribeToRoom(friendlyId, joinUrl) {
  consumer.subscriptions.create({
    channel: 'RoomsChannel',
    friendly_id: friendlyId,
  }, {
    connected() {
      // Called when the subscription is ready for use on the server
      console.log('connected');
      console.log(joinUrl);
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
      console.log('disconnected');
    },

    received() {
      // Called when there's incoming data on the websocket for this channel
      console.log('received');
      console.log(joinUrl);
      window.location.replace(joinUrl);
    },
  });
}
