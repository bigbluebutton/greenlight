import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRole(roleId) {
  return useQuery(
    ['getRole', roleId.toString()],
    () => axios.get(`/admin/roles/${roleId}.json`).then((resp) => resp.data.data),
  );
}
