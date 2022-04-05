import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

const createSession = (sessionUser) => axios.post(ENDPOINTS.signin, sessionUser)
  .then((resp) => resp.data)
  .catch((error) => console.log(error));

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

  const handleSignIn = (userSession) => mutation.mutateAsync(userSession).catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleSignIn, ...mutation };
}
