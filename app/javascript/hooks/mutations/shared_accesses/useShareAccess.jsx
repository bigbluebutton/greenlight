import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useShareAccess({ friendlyId, closeModal }) {
  const queryClient = useQueryClient();

  const shareAccess = (users) => axios.post('/api/v1/shared_accesses.json', { friendly_id: friendlyId, users });

  const mutation = useMutation(shareAccess, {
    onSuccess: () => {
      closeModal();
      queryClient.invalidateQueries('getSharedUsers');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
