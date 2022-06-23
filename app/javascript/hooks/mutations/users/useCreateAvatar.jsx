import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { toast } from 'react-hot-toast';

export default function useCreateAvatar(currentUser) {
  const queryClient = useQueryClient();

  const createAvatar = (data) => {
    const formData = new FormData();
    formData.append('user[avatar]', data.avatar[0]);
    return axios.patch(`/api/v1/users/${currentUser.id}.json`, formData);
  };

  const mutation = useMutation(
    createAvatar,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        toast.success('Avatar updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
