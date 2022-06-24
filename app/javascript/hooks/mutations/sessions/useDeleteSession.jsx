import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { toast } from 'react-hot-toast';

const deleteSession = () => axios.delete('/api/v1/sessions/signout.json');

export default function useDeleteSession() {
  const queryClient = useQueryClient();
  const mutation = useMutation(deleteSession, {
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
    onSuccess: () => {
      queryClient.invalidateQueries('useSessions');
      toast.success('Logged out');
    },
  });

  const handleSignOut = () => mutation.mutateAsync().catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleSignOut, ...mutation };
}
