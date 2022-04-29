import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

const createUser = (data) => axios.post(ENDPOINTS.signup, data);

export default function useCreateUser() {
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
  const onSubmit = (userData) => mutation.mutateAsync({ user: userData }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
