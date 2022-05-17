import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoomSettings(friendlyId) {
  return useQuery('getRoomSettings', () => axios.get(`/api/v1/room_settings/${friendlyId}.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
