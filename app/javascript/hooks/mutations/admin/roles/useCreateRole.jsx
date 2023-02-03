import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useCreateRole({ onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (role) => axios.post('/admin/roles.json', { role }),
    {
      onSuccess: () => {
        toast.success(t('toast.success.role.role_created'));
        queryClient.invalidateQueries('getRoles');
      },
      onError: () => { toast.error(t('toast.error.problem_completing_action')); },
      onSettled,
    },
  );
}
