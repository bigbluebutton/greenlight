import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting(friendlyId) {
  const queryClient = useQueryClient();

  // If guestPolicy setting is toggled, bool are rewritten to string values as per BBB API.
  const rewriteRoomSettingData = (roomSettingData) => {
    if (roomSettingData.settingName === 'guestPolicy') {
      Object.defineProperty(roomSettingData, 'settingValue', {
        value: roomSettingData.settingValue === true ? 'ASK_MODERATOR' : 'ALWAYS_ACCEPT',
      });
    }
    return roomSettingData;
  };

  const patchRoomSetting = (roomSettingData) => axios.patch(`/room_settings/${friendlyId}.json`, roomSettingData);

  const mutation = useMutation(patchRoomSetting, {
    onSuccess: () => {
      queryClient.invalidateQueries('useRoom');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
    onMutate: (roomSettingData) => rewriteRoomSettingData(roomSettingData),
  });

  const handleUpdateRoomSetting = (roomSettingData) => {
    mutation.mutateAsync(roomSettingData).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { handleUpdateRoomSetting, ...mutation };
}
