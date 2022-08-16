import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useDeleteServerRoom({ friendlyId, onSettled }) {
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/rooms/${friendlyId}.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getServerRooms');
        toast.success('Server room deleted.');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      onSettled,
    },
  );
}
