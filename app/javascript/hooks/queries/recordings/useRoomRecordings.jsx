import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomRecordings(friendlyId, input) {
  const params = {
    q: input,
  };
  return useQuery(
    ['getRoomRecordings', input],
    () => axios.get(`/rooms/${friendlyId}/recordings.json`, { params }).then((resp) => resp.data.data),
  );
}
