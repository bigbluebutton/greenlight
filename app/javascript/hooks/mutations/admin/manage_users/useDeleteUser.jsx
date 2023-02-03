import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useDeleteUser(userId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/users/${userId}.json`, data),
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
