import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeleteSession() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete('/sessions/signout.json'),
    {
      onSuccess: () => {
        queryClient.setQueryData('useSessions', { signed_in: false, signed_out: true });
        toast.success(t('toast.success.session.signed_out'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
