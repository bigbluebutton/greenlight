import { useQuery } from 'react-query';
import axios from 'axios';

export default function useUser(userId) {
  return useQuery(['getUser', userId], () => axios.get(`/api/v1/users/${userId}.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
