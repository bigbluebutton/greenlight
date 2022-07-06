import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteSharedAccess(friendlyId) {
  const queryClient = useQueryClient();

  const deleteSharedAccess = (data) => axios.delete(`/shared_accesses/${friendlyId}.json`, { data });

  const mutation = useMutation(
    deleteSharedAccess,
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

  const handleDeleteSharedAccess = (user) => mutation.mutateAsync(user).catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleDeleteSharedAccess, ...mutation };
}
