import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { toast } from 'react-hot-toast';

export default function useDeleteAvatar(currentUser) {
  const queryClient = useQueryClient();

  const deleteAvatar = (data) => axios.delete(`/api/v1/users/${currentUser.id}/purge_avatar.json`, data);

  const mutation = useMutation(
    deleteAvatar,
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
