import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useUpdateRole(roleId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (role) => axios.patch(`/admin/roles/${roleId}.json`, { role }),
    {
      onError: () => { toast.error(t('toast.error.problem_completing_action')); },
      onSuccess: () => {
        toast.success(t('toast.success.role_updated'));
        queryClient.invalidateQueries('getRoles');
        queryClient.invalidateQueries(['getRole', roleId.toString()]);
      },
    },
  );
}
