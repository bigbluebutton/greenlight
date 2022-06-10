import { useMutation, useQueryClient } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useUpdateRecording(recordId) {
  const updateRecording = (recordingData) => axios.put(ENDPOINTS.updateRecording(recordId), recordingData);
  const queryClient = useQueryClient();
  const mutation = useMutation(
    updateRecording,
    { // Mutation config.
      mutationKey: ENDPOINTS.updateRecording(recordId),
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: () => {
        queryClient.invalidateQueries('getRecordings');
      },
    },
  );
  const onSubmit = (recordingData) => mutation.mutateAsync({ recording: recordingData }).catch(() => { });
  return { onSubmit, ...mutation };
}
