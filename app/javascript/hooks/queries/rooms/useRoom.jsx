import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoom(friendlyId) {
  return useQuery(
    ['getRoom', { friendlyId }],
    () => axios.get(`/rooms/${friendlyId}.json`).then((resp) => resp.data.data),
    {
      retry: false,
    },
  );
}
