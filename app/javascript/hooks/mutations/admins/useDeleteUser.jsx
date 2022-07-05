import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';

export default function useUpdateUser(userId) {
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const mutation = useMutation(
    (data) => axios.delete(`/api/v1/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        toast.success('User deleted');
        navigate('/adminpanel/users');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
  const onSubmit = (userData) => mutation.mutateAsync({ user: userData }).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
