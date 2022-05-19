import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteRecording() {
  const deleteRecording = (recordingData) => axios.delete(`/api/v1/recordings/${recordingData.recordId}.json`);
  const queryClient = useQueryClient();

  const mutation = useMutation(deleteRecording, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRecordings');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const handleDeleteRecording = (recordingData) => {
    mutation.mutateAsync(recordingData).catch(/* Prevents the promise exception from bubbling */() => {});
  };

  return { handleDeleteRecording, ...mutation };
}
