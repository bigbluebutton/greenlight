import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSharedUsers(friendlyId, input, setSharedUsers) {
  return useQuery(['getSharedUsers', input], () => axios.get(`/shared_accesses/${friendlyId}.json`, {
    params: {
      search: input,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => setSharedUsers(resp.data.data)));
}
