import { useQuery, useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

// export default function useDeleteRoom(friendlyId) {
//   return useQuery('deleteRoom',() => axios.delete(`/api/v1/rooms/${friendlyId}.json`, {
//     headers: {
//       'Content-Type': 'application/json',
//       Accept: 'application/json',
//     },enabled:false,
//   }).then((resp) => console.log('room deleted!')));
// }

export default function useDeleteRoom(friendlyId) {
  const deleteRoom = () => axios.delete(`/api/v1/rooms/${friendlyId}.json`);
  const navigate = useNavigate();

  const mutation = useMutation(deleteRoom, {
    onSuccess: () => {
      `/api/v1/rooms/${friendlyId}.json`,
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
