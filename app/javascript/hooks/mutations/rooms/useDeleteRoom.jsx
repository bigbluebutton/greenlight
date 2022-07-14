import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteRoom({ friendlyId, onSettled }) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/rooms/${friendlyId}.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRooms');
        navigate('/rooms');
        toast.success('Room deleted');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      onSettled,
    },
  );
}
