import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useShareAccess({ friendlyId, closeModal }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.post('/shared_accesses.json', { friendly_id: friendlyId, shared_users: data.shared_users }),
    {
      onSuccess: () => {
        closeModal();
        queryClient.invalidateQueries('getSharedUsers');
        toast.success(t('toast.success.room.room_shared'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
