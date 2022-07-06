import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useEnv() {
  return useQuery(
    'getEnv',
    () => axios.get('/env.json').then((resp) => resp.data.data),
  );
}
