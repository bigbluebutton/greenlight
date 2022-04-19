import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

export default function useDeleteRoom(friendlyId) {
  const deleteRoom = () => axios.delete(`/api/v1/rooms/${friendlyId}.json`);
  const navigate = useNavigate();

  const mutation = useMutation(deleteRoom, {
    onSuccess: () => {
      navigate('/rooms');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const handleDeleteRoom = async () => {
    await mutation.mutateAsync();
  };

  return { handleDeleteRoom, ...mutation };
}
