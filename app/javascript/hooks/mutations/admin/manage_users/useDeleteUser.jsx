import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useDeleteUser(userId) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/admin/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
        toast.success('User deleted');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
