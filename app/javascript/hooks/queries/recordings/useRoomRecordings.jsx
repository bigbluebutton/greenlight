import { useQuery } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useRoomRecordings(friendlyId) {
  return useQuery('getRoomRecordings', () => axios.get(ENDPOINTS.room_recordings(friendlyId), {
  }).then((resp) => resp.data.data));
}
