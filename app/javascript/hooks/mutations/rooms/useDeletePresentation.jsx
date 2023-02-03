import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeletePresentation(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/rooms/${friendlyId}/purge_presentation.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        toast.success(t('toast.success.room.presentation_deleted'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
