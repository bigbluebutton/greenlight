import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteSharedAccess(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/shared_accesses/${friendlyId}.json`, { data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
        toast.success('Unshared the room');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
