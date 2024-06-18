import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useRevokeUserInvite() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (id) => axios.delete(`/admin/invitations/${id}.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getInvitations']);
        toast.success(t('toast.success.invitations.invitation_revoked'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
