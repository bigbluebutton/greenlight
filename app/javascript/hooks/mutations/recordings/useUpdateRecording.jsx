import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useUpdateRecording(recordId) {
  const updateRecording = (recordingData) => axios.put(ENDPOINTS.updateRecording(recordId), recordingData);
  const queryClient = useQueryClient();
  const mutation = useMutation(
    updateRecording,
    { // Mutation config.
      mutationKey: ENDPOINTS.updateRecording(recordId),
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        queryClient.invalidateQueries('getRecordings');
        toast.success('Recording name updated');
      },
    },
  );
  const onSubmit = (recordingData) => mutation.mutateAsync({ recording: recordingData }).catch(() => { });
  return { onSubmit, ...mutation };
}
