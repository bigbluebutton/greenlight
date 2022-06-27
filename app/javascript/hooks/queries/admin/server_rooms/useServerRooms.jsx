import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useServerRooms(input, setServerRooms) {
  return useQuery(['getServerRooms', input], () => axios.get('/admin/server_rooms.json', {
    params: {
      search: input,
    },
  })
    .then((resp) => setServerRooms(resp.data.data)));
}
