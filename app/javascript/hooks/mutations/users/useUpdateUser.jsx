import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateUser(userId) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries(['getUser', userId.toString()]);
        toast.success('User updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
