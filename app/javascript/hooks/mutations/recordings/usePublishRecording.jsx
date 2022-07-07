import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function usePublishRecording() {
  const queryClient = useQueryClient();

  return useMutation(
    (visibilityData) => axios.post('/recordings/publish.json', visibilityData),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRecordings');
        toast.success('Recording visibility updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
