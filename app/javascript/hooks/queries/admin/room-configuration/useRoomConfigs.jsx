import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useRoomConfigs() {
  return useQuery(
    'getRoomsConfigs',
    () => axios.get('/rooms_configurations.json').then((resp) => resp.data.data),
  );
}
