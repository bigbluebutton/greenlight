import { useQuery } from 'react-query';
import axios from 'axios';

export default function useShareableUsers(friendlyId) {
  return useQuery('getShareableUsers', () => axios.get(`/api/v1/shared_accesses/${friendlyId}/shareable_users.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
