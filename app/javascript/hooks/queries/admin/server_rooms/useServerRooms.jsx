import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import axios from '../../../../helpers/Axios';

export default function useServerRooms(input, page) {
  const [searchParams] = useSearchParams();

  const params = {
    'sort[column]': searchParams.get('sort[column]'),
    'sort[direction]': searchParams.get('sort[direction]'),
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
