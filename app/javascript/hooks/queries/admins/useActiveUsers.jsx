import { useQuery } from 'react-query';
import axios from 'axios';

export default function useActiveUsers(input, setActiveUsers) {
  return useQuery(['getAdminUsers', input], () => axios.get('/api/v1/admin/admins/active_users.json', {
    params: {
      search: input,
    },
  }).then((resp) => setActiveUsers(resp.data.data)));
}
