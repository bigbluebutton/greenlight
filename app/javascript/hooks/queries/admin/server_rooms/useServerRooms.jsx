import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useServerRooms(input, page) {
  const params = {
    search: input,
    page,
  };

  return useQuery(
    ['getServerRooms', { ...params }],
    () => axios.get('/admin/server_rooms.json', { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
