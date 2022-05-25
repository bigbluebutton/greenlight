import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteRecording(recordId) {
  const deleteRecording = () => axios.delete(`/api/v1/recordings/${recordId}.json`);
  const queryClient = useQueryClient();

  const mutation = useMutation(deleteRecording, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRecordings');
      queryClient.invalidateQueries('getRoomRecordings');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const handleDeleteRecording = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeleteRecording, ...mutation };
}
