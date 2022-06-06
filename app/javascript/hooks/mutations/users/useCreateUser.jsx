import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateUser() {
  const createUser = ({ user, token }) => axios.post(ENDPOINTS.signup, { user, token });
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const mutation = useMutation(
    createUser,
    { // Mutation config.
      mutationKey: ENDPOINTS.signup,
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        navigate('/rooms');
      },
    },
  );
  const onSubmit = (user, token) => mutation.mutateAsync({ user, token }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
