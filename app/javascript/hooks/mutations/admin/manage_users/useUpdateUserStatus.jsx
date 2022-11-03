import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useUpdateUserStatus() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/admin/users/${data.id}.json`, { user: { status: data.status } }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getPendingUsers']);
        queryClient.invalidateQueries(['getBannedUsers']);
        queryClient.invalidateQueries(['getAdminUsers']);

        toast.success(t('toast.success.user.user_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
