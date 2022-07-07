import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteAvatar(currentUser) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/users/${currentUser.id}/purge_avatar.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries('getUser');
        toast.success('Avatar updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
