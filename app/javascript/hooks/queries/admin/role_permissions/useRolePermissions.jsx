import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRolePermissions(roleId) {
  const params = {
    role_id: roleId,
  };

  return useQuery(
    ['getRolePermissions', { ...params }],
    () => axios.get('/admin/role_permissions.json', { params }).then((resp) => resp.data.data),
  );
}
