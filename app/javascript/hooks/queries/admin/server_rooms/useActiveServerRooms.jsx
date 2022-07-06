import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useActiveServerRooms() {
  return useQuery('getServerRooms', () => axios.get('/admin/server_rooms/active_server_rooms.json')
    .then((resp) => resp.data.data));
}
