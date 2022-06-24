import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { toast } from 'react-hot-toast';

export default function useDeleteRecording(recordId) {
  const deleteRecording = () => axios.delete(`/api/v1/recordings/${recordId}.json`);
  const queryClient = useQueryClient();

  const mutation = useMutation(deleteRecording, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRecordings');
      queryClient.invalidateQueries('getRoomRecordings');
      toast.success('Recording deleted');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const handleDeleteRecording = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeleteRecording, ...mutation };
}
