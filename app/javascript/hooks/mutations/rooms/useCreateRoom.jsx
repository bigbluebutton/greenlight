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

import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useCreateRoom({ userId, onSettled }) {
  const { t } = useTranslation();

  const ROOMSLISTQUERYKEY = ['getRooms', { search: '' }]; // TODO: amir - create a central store for query keys.
  const queryClient = useQueryClient();

  // Optimistically adds the room to the rooms querries cache.
  const optimisticCreateRoom = async (data) => {
    const newRoom = { ...data };
    // Prepare the new room to be cached.
    newRoom.friendly_id = `${Date.now()}`; // TODO: amir - Revisit this.
    newRoom.optimistic = true; // Mark the room object as optimistic.

    // Cancel any outgoing refetches (so they don't overwrite our optimistic update)
    await queryClient.cancelQueries(ROOMSLISTQUERYKEY);

    // Snapshot the previous value
    const oldRooms = queryClient.getQueryData(ROOMSLISTQUERYKEY);
    // Optimistically update to the new value
    queryClient.setQueryData(ROOMSLISTQUERYKEY, (old) => old?.concat([newRoom]));

    // Return a context object with the snapshotted value
    return { oldRooms };
  };

  return useMutation(
    (room) => axios.post('/rooms.json', { room, user_id: userId }),
    { // Mutation config.
      onMutate: optimisticCreateRoom,
      onSuccess: () => { toast.success(t('toast.success.room.room_created')); },
      // If the mutation fails, use the context returned from onMutate to roll back

      onError: (err, newRoom, context) => {
        queryClient.setQueryData(ROOMSLISTQUERYKEY, context.oldRooms);
        // specifc toast for room limit being met
        if (err.response.data.errors === 'RoomLimitError') {
          toast.error(t('toast.error.rooms.room_limit'));
        } else {
          toast.error(t('toast.error.problem_completing_action'));
        }
      },
      // Always refetch after error or success:
      onSettled: () => {
        queryClient.invalidateQueries(ROOMSLISTQUERYKEY);
        onSettled();
      },
    },
  );
}
