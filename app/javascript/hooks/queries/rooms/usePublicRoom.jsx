import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function usePublicRoom(friendlyId) {
  return useQuery(
    'getRoom',
    () => axios.get(`/rooms/${friendlyId}/public.json`).then((resp) => resp.data.data),
  );
}
