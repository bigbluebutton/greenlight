import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeleteSharedAccess(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.delete(`/shared_accesses/${friendlyId}.json`, { data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
        toast.success(t('toast.success.room.room_unshared'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
