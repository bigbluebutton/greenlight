import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function usePublishRecording() {
  const updatePublish = (visibilityData) => axios.post('/recordings/publish.json', visibilityData);
  const queryClient = useQueryClient();
  const mutation = useMutation(updatePublish, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRecordings');
      toast.success('Recording visibility updated');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const handlePublishRecording = (visibilityData) => mutation.mutateAsync(visibilityData)
    .catch(/* Prevents the promise exception from bubbling */() => {});
  return { handlePublishRecording, ...mutation };
}
