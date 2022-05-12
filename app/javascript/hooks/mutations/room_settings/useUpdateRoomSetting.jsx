import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting(friendlyId) {
  const patchRoomSetting = (roomSettingData) => axios.patch(`/room_settings/${friendlyId}.json`, roomSettingData);

  const queryClient = useQueryClient();

  const mutation = useMutation(patchRoomSetting, {
    // Re-fetch the current_user and redirect to homepage if Mutation is successful.
    onSuccess: () => {
      queryClient.invalidateQueries('useRoom');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const handleUpdateRoomSetting = (roomSettingData) => {
    mutation.mutateAsync(roomSettingData).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { handleUpdateRoomSetting, ...mutation };
}
