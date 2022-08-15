import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting(friendlyId) {
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
        toast.success('Room settings updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
