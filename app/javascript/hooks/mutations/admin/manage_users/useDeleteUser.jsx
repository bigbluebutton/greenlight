import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useDeleteUser(userId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/admin/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
        toast.success(t('toast.success.user.user_deleted'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
