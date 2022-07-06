import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useServerRooms(input, setServerRooms) {
  const params = {
    search: input,
  };

  return useQuery(
    ['getServerRooms', input],
    () => axios.get('/admin/server_rooms.json', { params }).then((resp) => setServerRooms(resp.data.data)),
  );
}
