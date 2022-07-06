import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useShareableUsers(friendlyId, input, setShareableUsers) {
  return useQuery(['getShareableUsers', input], () => axios.get(`/shared_accesses/${friendlyId}/shareable_users.json`, {
    params: {
      search: input,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => setShareableUsers(resp.data.data)));
}
