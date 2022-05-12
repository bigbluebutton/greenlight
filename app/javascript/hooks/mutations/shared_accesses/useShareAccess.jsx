import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useShareAccess({ roomId, closeModal }) {
  const queryClient = useQueryClient();

  const shareAccess = (sharedAccessUsers) => {
    axios.post(`/api/v1/shared_accesses/room.json`, sharedAccessUsers);
  };

  const delay = (time) => new Promise((resolve) => {
    setTimeout(resolve, time);
  });

  const mutation = useMutation(shareAccess, {
    onSuccess: async () => {
      closeModal();
      await delay(100);
      queryClient.invalidateQueries('getSharedUsers');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
