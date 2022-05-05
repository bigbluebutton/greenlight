import consumer from './consumer';

export default function subscribeToRoom(friendlyId) {
  consumer.subscriptions.create({
    channel: 'RoomsChannel',
    friendly_id: friendlyId,
  }, {
    connected() {
      // Called when the subscription is ready for use on the server
      console.log('connected');
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
      console.log('disconnected');
    },

    received(joinUrl) {
      // Called when there's incoming data on the websocket for this channel
      console.log('received');
      window.location.replace(joinUrl);
    },
  });
}
