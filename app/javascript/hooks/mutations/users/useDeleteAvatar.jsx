import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteAvatar(currentUser) {
  const queryClient = useQueryClient();

  const deleteAvatar = (data) => axios.delete(`/users/${currentUser.id}/purge_avatar.json`, data);

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
