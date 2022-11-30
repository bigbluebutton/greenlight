import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function usePublicRoom(friendlyId) {
  return useQuery(
    'getRoom',
    () => axios.get(`/instant_rooms/${friendlyId}/show.json`).then((resp) => resp.data.data),
    {
      retry: 1,
      cacheTime: 0, // No caching.
    },
  );
}
