import consumer from './consumer';

export default function subscribeToRoom(friendlyId, joinUrl) {
  consumer.subscriptions.create({
    channel: 'RoomsChannel',
    friendly_id: friendlyId,
  }, {
    connected() {},

    disconnected() {},

    received() {
      // Called when there's incoming data on the websocket for this channel
      window.location.replace(joinUrl);
    },
  });
}
