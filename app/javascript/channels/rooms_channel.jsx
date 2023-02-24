// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
