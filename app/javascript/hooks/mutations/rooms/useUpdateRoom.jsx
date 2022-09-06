import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRoom({ friendlyId }) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/rooms/${friendlyId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRoom');
        toast.success('Room updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
