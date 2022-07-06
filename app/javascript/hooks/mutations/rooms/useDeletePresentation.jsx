import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeletePresentation(friendlyId) {
  const deletePresentation = () => axios.delete(`/rooms/${friendlyId}/purge_presentation.json`);
  const queryClient = useQueryClient();

  const mutation = useMutation(deletePresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
      toast.success('Presentation deleted');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const handleDeletePresentation = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeletePresentation, ...mutation };
}
