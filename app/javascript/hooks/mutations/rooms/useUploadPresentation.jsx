import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useUploadPresentation(friendlyId) {
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    const formData = new FormData();
    formData.append('presentation', data);
    axios.patch(`/api/v1/rooms/${friendlyId}.json`, formData);
  };

  const delay = (time) => new Promise((resolve) => {
    setTimeout(resolve, time);
  });

  const mutation = useMutation(
    uploadPresentation,
    {
      onSuccess: async () => {
        await delay(500);
        queryClient.invalidateQueries('getRoom');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );

  const onSubmit = (data) => {
    // console.log(data)
    mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
