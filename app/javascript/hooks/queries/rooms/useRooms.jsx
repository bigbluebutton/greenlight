import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRooms() {
  return useQuery('getRooms', () => axios.get('/api/v1/rooms.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    refetchInterval: 10000,
    refetchIntervalInBackground: true,
  }).then((resp) => resp.data.data));
}
