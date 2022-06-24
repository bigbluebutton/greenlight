import { useQuery } from 'react-query';
import axios from 'axios';

export default function useActiveUsers() {
  return useQuery('getAdminUsers', () => axios.get('/api/v1/admin/admins/active_users.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
