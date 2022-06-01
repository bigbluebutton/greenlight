import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateSession(token) {
  const createSession = (session) => axios.post(ENDPOINTS.signin, { session, token });
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

  const onSubmit = (session) => mutation.mutateAsync(session).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
