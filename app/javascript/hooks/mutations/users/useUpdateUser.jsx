import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useUpdateUser(userId) {
  const queryClient = useQueryClient();

  const mutation = useMutation(
    (data) => axios.patch(`/api/v1/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );
  const onSubmit = (userData) => mutation.mutateAsync({ user: userData }).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
