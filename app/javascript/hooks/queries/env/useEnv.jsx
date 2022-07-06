import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useEnv() {
  return useQuery('getEnv', () => axios.get('/env.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
