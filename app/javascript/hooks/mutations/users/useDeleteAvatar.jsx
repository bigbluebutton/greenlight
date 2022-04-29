import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteAvatar(currentUser) {
  const queryClient = useQueryClient();

  const deleteAvatar = (data) => {
    axios.delete(`/api/v1/users/${currentUser.id}/purge_avatar.json`, data);
  };

  const delay = (time) => new Promise((resolve) => {
    setTimeout(resolve, time);
  });

  const mutation = useMutation(
    deleteAvatar,
    {
      onSuccess: async () => {
        await delay(500);
        queryClient.invalidateQueries('useSessions');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
