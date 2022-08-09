import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useCreateServerRoom({ userID, onSettled }) {
  const queryClient = useQueryClient();

  return useMutation(
    (room) => axios.post(`/admin/users/${userID}/create_server_room.json`, { room }),
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
