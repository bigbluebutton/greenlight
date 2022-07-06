import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomSettings(friendlyId) {
  return useQuery(
    ['getRoomSettings', friendlyId],
    () => axios.get(`/room_settings/${friendlyId}.json`).then((resp) => resp.data.data),
  );
}
