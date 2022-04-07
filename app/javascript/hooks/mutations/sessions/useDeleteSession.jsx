import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

const deleteSession = () => axios.delete('/api/v1/sessions/signout.json');

export default function useDeleteSession() {
  const queryClient = useQueryClient();
  const mutation = useMutation(deleteSession, {
    onError: (error) => {
      console.log(error);
    },
    onSuccess: () => {
      queryClient.invalidateQueries('useSessions');
    },
  });

  const handleSignOut = () => mutation.mutateAsync().catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleSignOut, ...mutation };
}
