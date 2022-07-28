import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useActiveUsers(input, page) {
  const params = {
    search: input,
    page,
  };

  return useQuery(
    ['getAdminUsers', { ...params }],
    () => axios.get('/admin/users/active_users.json', { params }).then((resp) => resp.data),
  );
}
