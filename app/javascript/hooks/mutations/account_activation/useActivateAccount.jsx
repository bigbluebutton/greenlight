import toast from 'react-hot-toast';
import { useMutation, useQueryClient } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useActivateAccount(token) {
  const queryClient = useQueryClient();
  const resetPwd = (data) => axios.post(ENDPOINTS.activateAccount, data);
  const mutation = useMutation(
    resetPwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.activateAccount,
      onError: (error) => {
        console.error('Error:', error.message);
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        toast.success('Account activated.');
      },
    },
  );
  const activate = () => mutation.mutate({ user: { token } });
  return { activate, ...mutation };
}
