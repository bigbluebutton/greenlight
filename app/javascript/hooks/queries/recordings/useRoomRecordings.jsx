import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomRecordings(friendlyId, input) {
  return useQuery(['getRoomRecordings', input], () => axios.get(`/rooms/${friendlyId}/recordings.json`, {
    params: {
      q: input,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
