import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';
import subscribeToRoom from '../../../channels/rooms_channel';

export default function useRoomJoin(friendlyId, name, accessCode) {
  const params = {
    name,
    access_code: accessCode,
  };

  return useQuery(
    ['getRoomJoin', name],
    () => axios.get(`/meetings/${friendlyId}/join.json`, { params }).then((resp) => { subscribeToRoom(friendlyId, resp.data); }),
    { enabled: false, retry: false },
  );
}
