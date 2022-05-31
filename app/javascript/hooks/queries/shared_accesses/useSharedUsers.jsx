import { useQuery } from 'react-query';
import axios from 'axios';

export default function useSharedUsers(friendlyId, input, setSharedUsers) {
  return useQuery(['getSharedUsers', input], () => axios.get(`/api/v1/shared_accesses/${friendlyId}.json`, {
    params: {
      search: input,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => setSharedUsers(resp.data.data)));
}
