import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useUploadPresentation(friendlyId) {
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    const formData = new FormData();
    formData.append('presentation', data);
    return axios.patch(`/api/v1/rooms/${friendlyId}.json`, formData);
  };

  const mutation = useMutation(uploadPresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
    },
    onError: (error) => {
      console.error('Error:', error.message);
    },
  });

  const onSubmit = async (data) => {
    await mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
