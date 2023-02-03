import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUpdateUser(userId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/users/${userId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries(['getUser', userId.toString()]);
        toast.success(t('toast.success.user.user_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
