import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteSharedAccess(roomId) {
  const queryClient = useQueryClient();

  const deleteSharedAccess = (data) => {
    axios.delete(`/api/v1/shared_accesses/room/${roomId}.json`, { data });
  };

  const delay = (time) => new Promise((resolve) => {
    setTimeout(resolve, time);
  });

  const mutation = useMutation(
    deleteSharedAccess,
    {
      onSuccess: async () => {
        await delay(100);
        queryClient.invalidateQueries('getSharedUsers');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
