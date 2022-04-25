import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function useUpdateUser(userId) {
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const mutation = useMutation(
    (data) => axios.delete(`/api/v1/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        navigate('/');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );
  const onSubmit = (userData) => mutation.mutateAsync({ user: userData }).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
