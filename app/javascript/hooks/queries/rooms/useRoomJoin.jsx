import { useQuery } from 'react-query';
import axios from 'axios';
import subscribeToRoom from '../../../channels/rooms_channel';

export default function useRoomJoin(friendlyId, name, accessCode) {
  return useQuery(
    ['getRoomJoin', name],
    () => axios.get(`/api/v1/meetings/${friendlyId}/join.json`, {
      params: {
        name,
        access_code: accessCode,
      },
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    }).then((resp) => {
      subscribeToRoom(friendlyId, resp.data.data);
    }),
    {
      enabled: false,
      retry: false,
    },
  );
}
