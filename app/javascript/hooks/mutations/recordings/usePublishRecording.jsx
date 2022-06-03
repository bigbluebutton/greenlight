import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function usePublishRecording() {
  const updatePublish = (visibilityData) => axios.post('/recordings/publish.json', { visibilityData });
  const queryClient = useQueryClient();
  const mutation = useMutation(updatePublish, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRecordings');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const handlePublishRecording = (visibilityData) => mutation.mutateAsync(visibilityData)
    .catch(/* Prevents the promise exception from bubbling */() => {});
  return { handlePublishRecording, ...mutation };
}
