import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoom(friendlyId, includeOwner = false) {
  return useQuery('getRoom', () => axios.get(`/rooms/${friendlyId}.json`, {
    params: {
      include_owner: includeOwner,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
