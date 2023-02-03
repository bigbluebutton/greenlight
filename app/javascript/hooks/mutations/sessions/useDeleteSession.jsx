import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function useDeleteSession({ showToast = true }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const currentUser = useAuth();

  return useMutation(
    () => axios.delete('/sessions/signout.json'),
    {
      onSuccess: async () => {
        currentUser.stateChanging = true;
        queryClient.refetchQueries('useSessions');
        await navigate('/');
        if (showToast) { toast.success(t('toast.success.session.signed_out')); }
        currentUser.stateChanging = false;
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
