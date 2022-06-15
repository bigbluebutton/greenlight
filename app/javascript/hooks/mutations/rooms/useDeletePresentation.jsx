import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeletePresentation(friendlyId) {
  const deletePresentation = () => axios.delete(`/api/v1/rooms/${friendlyId}/purge_presentation.json`);
  const queryClient = useQueryClient();

  const mutation = useMutation(deletePresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
    },
    onError: (error) => {
      console.error('Error:', error.message);
    },
  });

  const handleDeletePresentation = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeletePresentation, ...mutation };
}
