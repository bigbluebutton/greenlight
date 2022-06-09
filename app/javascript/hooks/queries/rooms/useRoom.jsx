import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoom(friendlyId, includeOwner = false) {
  return useQuery('getRoom', () => axios.get(`/api/v1/rooms/${friendlyId}.json`, {
    params: {
      include_owner: includeOwner,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
