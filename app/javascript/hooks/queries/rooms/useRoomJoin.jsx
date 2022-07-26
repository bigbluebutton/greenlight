import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';
import subscribeToRoom from '../../../channels/rooms_channel';

export default function useRoomJoin(friendlyId, name, accessCode) {
  const params = {
    name,
    access_code: accessCode,
  };
  return useQuery(
    ['getRoomStatus', name],
    () => axios.get(`/meetings/${friendlyId}/status.json`, { params }).then((resp) => {
      const response = resp.data.data;
      if (response.status) {
        window.location.replace(response.joinUrl);
      } else {
        subscribeToRoom(friendlyId, response.joinUrl);
      }
    }),
    { enabled: false, retry: false },
  );
}
