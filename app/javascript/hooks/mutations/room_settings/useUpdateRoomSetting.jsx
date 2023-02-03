import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
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

  // Returns a more suiting toast message if the updated room setting is an access code
  const toastSuccess = (variables) => {
    if ((variables.settingName === 'glModeratorAccessCode' || variables.settingName === 'glViewerAccessCode') && variables.settingValue === true) {
      return toast.success(t('toast.success.room.access_code_generated'));
    }
    if ((variables.settingName === 'glModeratorAccessCode' || variables.settingName === 'glViewerAccessCode') && variables.settingValue === false) {
      return toast.success(t('toast.success.room.access_code_deleted'));
    }
    return toast.success(t('toast.success.room.room_setting_updated'));
  };

  return useMutation(
    updateRoomSetting,
    {
      onSuccess: (data, variables) => {
        queryClient.invalidateQueries('getRoomSettings');
        toastSuccess(variables);
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
