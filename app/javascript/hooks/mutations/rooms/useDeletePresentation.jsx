import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeletePresentation(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/rooms/${friendlyId}/purge_presentation.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRoom');
        toast.success('Presentation deleted');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
