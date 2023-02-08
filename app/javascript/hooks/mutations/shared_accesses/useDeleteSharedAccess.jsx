import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useDeleteSharedAccess(friendlyId, redirect = false) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.delete(`/shared_accesses/${friendlyId}.json`, { data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
        queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        if (redirect) {
          navigate('/rooms');
        }
        toast.success(t('toast.success.room.room_unshared'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
