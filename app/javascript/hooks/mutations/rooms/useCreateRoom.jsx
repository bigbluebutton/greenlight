import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
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
        toast.error(t('toast.error.problem_completing_action'));
      },
      // Always refetch after error or success:
      onSettled: () => {
        queryClient.invalidateQueries(ROOMSLISTQUERYKEY);
        onSettled();
      },
    },
  );
}
