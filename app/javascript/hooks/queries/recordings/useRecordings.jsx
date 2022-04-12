import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRecordings() {
  return useQuery('getRecordings', () => axios.get('/api/v1/recordings.json', {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
