import { useQuery } from 'react-query';
import axios from 'axios';

export default function useEnv() {
  return useQuery('getEnv', () => axios.get('/api/v1/env.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
