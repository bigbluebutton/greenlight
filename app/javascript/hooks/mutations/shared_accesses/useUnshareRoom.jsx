import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

// Similar to useDeleteSharedAccess, but this one is specifically for unsharing a room that is shared with a user as the user
export default function useUnshareRoom(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post(`/shared_accesses/${friendlyId}/unshare_room.json`, { data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
        queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        navigate('/rooms');
        toast.success(t('toast.success.room.room_unshared'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
