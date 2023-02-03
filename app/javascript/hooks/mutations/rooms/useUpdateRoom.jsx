import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUpdateRoom({ friendlyId }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/rooms/${friendlyId}.json`, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        toast.success(t('toast.success.room.room_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
