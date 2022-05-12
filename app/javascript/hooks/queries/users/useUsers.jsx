import { useQuery } from 'react-query';
import axios from 'axios';

export default function useUsers() {
  return useQuery('getUsers', async () => axios.get('/api/v1/users.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
