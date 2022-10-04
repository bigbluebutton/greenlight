import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRooms(search) {
  const params = {
    search,
  };

  return useQuery(
    ['getRooms', { ...params }],
    () => axios.get('/rooms.json', { params }).then((resp) => resp.data.data),
    {
      refetchInterval: 10000,
      refetchIntervalInBackground: true,
      keepPreviousData: true,
    },
  );
}
