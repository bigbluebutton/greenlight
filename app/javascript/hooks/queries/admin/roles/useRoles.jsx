import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRoles(query) {
  const params = {
    search: query,
  };

  return useQuery(
    ['getRoles', query],
    () => axios.get('/admin/roles.json', { params }).then((resp) => resp.data.data),
  );
}
