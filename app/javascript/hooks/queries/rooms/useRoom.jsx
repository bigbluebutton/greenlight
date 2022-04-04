import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoom(friendlyId) {
  return useQuery('getRoom', () => axios.get(`/api/v1/rooms/${friendlyId}.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
