import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useCreateAvatar(currentUser) {
  const queryClient = useQueryClient();

  async function createAvatar(avatar) {
    // TODO - samuel: how to validate if toBlob() will transform any file into a png by default
    const avatarBlob = await new Promise((resolve) => {
      avatar.toBlob(resolve);
    });
    const formData = new FormData();
    formData.append('user[avatar]', avatarBlob);
    return axios.patch(`/users/${currentUser.id}.json`, formData);
  }

  const mutation = useMutation(
    createAvatar,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries('getUser');
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
