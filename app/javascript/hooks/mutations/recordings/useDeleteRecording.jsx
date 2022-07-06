import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteRecording(recordId) {
  const deleteRecording = () => axios.delete(`/recordings/${recordId}.json`);
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
