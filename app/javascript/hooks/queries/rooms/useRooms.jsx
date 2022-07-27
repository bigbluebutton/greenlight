import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRooms(page) {
  const params = {
    page,
  };

  return useQuery(
    ['getRooms', { ...params }],
    () => axios.get('/rooms.json', { params, refetchInterval: 10000, refetchIntervalInBackground: true }).then((resp) => resp.data),
  );
}
