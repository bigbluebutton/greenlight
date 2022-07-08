import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRecordingVisibility() {
  const queryClient = useQueryClient();

  return useMutation(
    (visibilityData) => axios.post('/recordings/update_visibility.json', visibilityData),
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
