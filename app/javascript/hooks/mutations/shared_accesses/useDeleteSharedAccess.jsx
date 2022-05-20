import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteSharedAccess(friendlyId) {
  const queryClient = useQueryClient();

  const deleteSharedAccess = (data) => axios.delete(`/api/v1/shared_accesses/${friendlyId}.json`, { data });

  const mutation = useMutation(
    deleteSharedAccess,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );

  const handleDeleteSharedAccess = (user) => mutation.mutateAsync(user).catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleDeleteSharedAccess, ...mutation };
}
