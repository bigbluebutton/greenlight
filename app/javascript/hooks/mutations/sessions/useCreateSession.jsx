import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useCreateSession(token) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (session) => axios.post('/sessions.json', { session, token }).then((resp) => resp.data.data),
    {
      onSuccess: (currentUser) => {
        queryClient.setQueryData('useSessions', currentUser);
        queryClient.invalidateQueries('useSessions');
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
