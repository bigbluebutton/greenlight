import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRoles(query) {
  return useQuery(['getRoles', query], () => axios.get('/admin/roles.json', {
    params: {
      search: query,
    },
  }).then((resp) => resp.data.data));
}
