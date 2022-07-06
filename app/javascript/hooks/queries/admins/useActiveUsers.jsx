import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useActiveUsers(input, setActiveUsers) {
  const params = {
    search: input,
  };

  return useQuery(
    ['getAdminUsers', input],
    () => axios.get('/admin/users/active_users.json', { params }).then((resp) => setActiveUsers(resp.data.data)),
  );
}
