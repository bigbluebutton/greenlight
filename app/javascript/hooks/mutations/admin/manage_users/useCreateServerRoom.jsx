import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useCreateServerRoom({ userId, onSettled }) {
  const queryClient = useQueryClient();

  return useMutation(
    (room) => axios.post('/rooms.json', { room, user_id: userId }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getServerRooms');
        toast.success('Room created');
      },
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSettled,
    },
  );
}
