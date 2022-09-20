import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeleteSession() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation(
    () => axios.delete('/sessions/signout.json'),
    {
      onSuccess: async () => {
        await queryClient.refetchQueries('useSessions');
        navigate('/');
        toast.success(t('toast.success.session.signed_out'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
