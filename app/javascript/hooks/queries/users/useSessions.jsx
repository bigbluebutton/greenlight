import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSessions() {
  return useQuery('useSessions', async () => axios.get('/sessions.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
