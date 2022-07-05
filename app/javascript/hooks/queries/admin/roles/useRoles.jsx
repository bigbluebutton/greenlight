import { useQuery } from 'react-query';
import axios, { ENDPOINTS } from '../../../../helpers/Axios';

export default function useRoles(query) {
  return useQuery(['getRoles', query], () => axios.get(ENDPOINTS.admin.getRoles, {
    params: {
      search: query,
    },
  }).then((resp) => resp.data.data));
}
