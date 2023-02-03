import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useUpdateRoomConfig(name) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (RoomsConfig) => axios.patch(`/admin/rooms_configurations/${name}.json`, { RoomsConfig }),
    {
      onError: () => { toast.error(t('toast.error.problem_completing_action')); },
      onSuccess: () => {
        toast.success(t('toast.success.room.room_configuration_updated'));
        queryClient.invalidateQueries('getRoomsConfigs');
      },
    },
  );
}
