import consumer from './consumer';

export default function subscribeToRoom(friendlyId, { onReceived }) {
  return consumer.subscriptions.create({
    channel: 'RoomsChannel',
    friendly_id: friendlyId,
  }, {
    connected() {
      console.info(`WS: Connected to room(friendly_id): ${friendlyId} channel.`);
    },

    disconnected() {
      console.info(`WS: Disconnected from room(friendly_id): ${friendlyId} channel.`);
    },

    received() {
      console.info(`WS: Received join signal on room(friendly_id): ${friendlyId}.`);

      if (onReceived) {
        onReceived();
      }
    },
  });
}
