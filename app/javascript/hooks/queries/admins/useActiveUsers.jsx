import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useActiveUsers(input, setActiveUsers) {
  return useQuery(['getAdminUsers', input], () => axios.get('/admin/users/active_users.json', {
    params: {
      search: input,
    },
  }).then((resp) => setActiveUsers(resp.data.data)));
}
