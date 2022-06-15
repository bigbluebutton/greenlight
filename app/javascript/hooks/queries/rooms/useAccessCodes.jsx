import { useQuery } from 'react-query';
import axios from 'axios';

export default function useAccessCodes(friendlyId) {
  return useQuery('getAccessCodes', () => axios.get(`/api/v1/rooms/${friendlyId}/access_codes.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
