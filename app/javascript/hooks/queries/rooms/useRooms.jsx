import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRooms() {
  return useQuery(
    'getRooms',
    () => axios.get('/rooms.json', { refetchInterval: 10000, refetchIntervalInBackground: true }).then((resp) => resp.data.data),
  );
}
