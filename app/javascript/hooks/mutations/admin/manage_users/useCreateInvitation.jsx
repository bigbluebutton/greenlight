import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useCreateInvitation({ onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (invitations) => axios.post('/admin/invitations.json', { invitations }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getInvitations');
        toast.success(t('toast.success.invitations.invitation_sent'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
      onSettled,
    },
  );
}
