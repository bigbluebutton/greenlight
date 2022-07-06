import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRecording(recordId) {
  const queryClient = useQueryClient();

  return useMutation(
    (recordingData) => axios.put(`/recordings/${recordId}.json`, recordingData),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRecordings');
        toast.success('Recording name updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
