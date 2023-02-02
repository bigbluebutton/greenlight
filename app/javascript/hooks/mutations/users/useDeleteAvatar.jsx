import { useMutation, useQueryClient } from 'react-query';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';
import Toast from '../../../helpers/ToastHelper';

export default function useDeleteAvatar(currentUser) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/users/${currentUser.id}/purge_avatar.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries('getUser');
        Toast.createSuccessToast(t('toast.success.user.avatar_updated'));
      },
      onError: () => {
        Toast.createErrorToast(t('toast.error.problem_completing_action'));
      },
    },
  );
}
