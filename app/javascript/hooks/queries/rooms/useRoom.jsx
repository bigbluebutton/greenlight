import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoom(friendlyId, includeOwner = false) {
  const params = {
    include_owner: includeOwner,
  };
  return useQuery(
    'getRoom',
    () => axios.get(`/rooms/${friendlyId}.json`, { params }).then((resp) => resp.data.data),
  );
}
