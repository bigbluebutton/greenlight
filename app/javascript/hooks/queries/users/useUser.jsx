import { useQuery } from 'react-query';
import axios from 'axios';

export default function useUser(userId) {
  return useQuery(
    ['getUser', userId],
    async () => axios.get(`/api/v1/users/${userId}.json`).then((resp) => resp.data.data),
  );
}
