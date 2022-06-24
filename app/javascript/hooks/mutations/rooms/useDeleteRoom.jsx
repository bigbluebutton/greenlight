import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-hot-toast';

export default function useDeleteRoom(friendlyId) {
  const deleteRoom = () => axios.delete(`/api/v1/rooms/${friendlyId}.json`);
  const navigate = useNavigate();

  const mutation = useMutation(deleteRoom, {
    onSuccess: () => {
      navigate('/rooms');
      toast.success('Room deleted');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const handleDeleteRoom = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeleteRoom, ...mutation };
}
