import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  // If guestPolicy setting is toggled, bool are rewritten to string values as per BBB API.
  const updateRoomSetting = (_data) => {
    const data = { ..._data };
    if (data.settingName === 'guestPolicy') {
      data.settingValue = data.settingValue ? 'ASK_MODERATOR' : 'ALWAYS_ACCEPT';
    }
    return axios.patch(`/room_settings/${friendlyId}.json`, data);
  };

  return useMutation(
    updateRoomSetting,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRoomSettings');
        toast.success(t('toast.success.room.room_setting_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
