import { useQuery } from 'react-query';
import axios from 'axios';
import subscribeToRoom from '../../../channels/rooms_channel';

export default function useRoomJoin(friendlyId, name) {
  return useQuery(
    ['getRoomJoin', name],
    () => axios.get(`/api/v1/rooms/${friendlyId}/join.json`, {
      params: {
        name,
      },
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    }).then((resp) => { subscribeToRoom(friendlyId, resp.data.data); }),
    {
      enabled: false,
    },
  );
}
