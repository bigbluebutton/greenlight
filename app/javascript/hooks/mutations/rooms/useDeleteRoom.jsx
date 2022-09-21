import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeleteRoom({ friendlyId, onSettled }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/rooms/${friendlyId}.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRooms');
        navigate('/rooms');
        toast.success(t('toast.success.room.room_deleted'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
      onSettled,
    },
  );
}
