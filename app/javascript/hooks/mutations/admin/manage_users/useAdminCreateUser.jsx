import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useAdminCreateUser({ onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (user) => axios.post('/users.json', { user }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
        toast.success(t('toast.success.user.user_created'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
      onSettled,
    },
  );
}
