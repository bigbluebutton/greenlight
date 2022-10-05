import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomRecordings(friendlyId, input, page) {
  const params = {
    q: input,
    page,
  };
  return useQuery(
    ['getRoomRecordings', { ...params, friendlyId }],
    () => axios.get(`/rooms/${friendlyId}/recordings.json`, { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
