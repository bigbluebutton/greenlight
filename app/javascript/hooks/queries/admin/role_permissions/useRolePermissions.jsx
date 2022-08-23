import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRolePermissions() {
  return useQuery(
    ['getRolePermissions'],
    () => axios.get('/admin/role_permissions.json').then((resp) => resp.data.data),
  );
}
