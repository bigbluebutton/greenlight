import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

const createSession = (userData) => axios.post(ENDPOINTS.signin, userData);

export default function useCreateSession() {
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const mutation = useMutation(createSession, {
    // Re-fetch the current_user and redirect to homepage if Mutation is successful.
    onSuccess: () => {
      queryClient.invalidateQueries('useSessions');
      navigate('/rooms');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const onSubmit = (userData) => mutation.mutateAsync(userData).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
