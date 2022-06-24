import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateRoom({ onSettled }) {
  const ROOMSLISTQUERYKEY = 'getRooms'; // TODO: amir - create a central store for query keys.
  const queryClient = useQueryClient();

  // Calls the Backend rooms API #create action to create the room.
  const createRoom = (roomData) => axios.post(ENDPOINTS.createRoom, roomData);

  // Optimistically adds the room to the rooms querries cache.
  const optimisticCreateRoom = async (data) => {
    const { room: newRoom } = data;
    // Prepare the new room to be cached.
    newRoom.friendly_id = `${Date.now()}`; // TODO: amir - Revisit this.
    newRoom.optimistic = true; // Mark the room object as optimistic.

    // Cancel any outgoing refetches (so they don't overwrite our optimistic update)
    await queryClient.cancelQueries(ROOMSLISTQUERYKEY);

    // Snapshot the previous value
    const oldRooms = queryClient.getQueryData(ROOMSLISTQUERYKEY);
    // Optimistically update to the new value
    queryClient.setQueryData(ROOMSLISTQUERYKEY, (old) => [...old, newRoom]);

    // Return a context object with the snapshotted value
    return { oldRooms };
  };

  const mutation = useMutation(
    createRoom,
    { // Mutation config.
      mutationKey: ENDPOINTS.createRoom,
      onMutate: optimisticCreateRoom,
      // If the mutation fails, use the context returned from onMutate to roll back
      onError: (err, newRoom, context) => {
        queryClient.setQueryData(ROOMSLISTQUERYKEY, context.oldRooms);
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      // Always refetch after error or success:
      onSettled: () => {
        queryClient.invalidateQueries(ROOMSLISTQUERYKEY);
        toast.success('Room created');
        onSettled();
      },
    },
  );

  const handleCreateRoom = (data) => mutation.mutateAsync({ room: data }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { handleCreateRoom, ...mutation };
}
