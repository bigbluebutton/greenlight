import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useUpdateRolePermission() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  return useMutation(
    (role) => axios.post('/admin/role_permissions.json', { role }),
    {
      onError: () => { toast.error(t('toast.error.problem_completing_action')); },
      onSuccess: () => {
        toast.success(t('toast.success.role.role_permission_updated'));
        queryClient.invalidateQueries('getRolePermissions');
        queryClient.invalidateQueries('useSessions');
      },
    },
  );
}
