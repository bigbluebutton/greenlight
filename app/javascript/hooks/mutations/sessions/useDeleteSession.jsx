import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

const deleteSession = () => axios.delete('/sessions/signout.json');

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
