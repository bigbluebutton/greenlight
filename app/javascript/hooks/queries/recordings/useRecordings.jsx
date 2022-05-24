import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRecordings(input, setRecordings) {
  return useQuery(['getRecordings', input], () => axios.get('/api/v1/recordings.json', {
    params: {
      search: input,
    },
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => {
    setRecordings(resp.data.data);
  }));
}
