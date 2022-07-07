import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteSession() {
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete('/sessions/signout.json'),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        toast.success('Logged out');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
