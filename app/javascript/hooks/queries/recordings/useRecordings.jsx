import { useQuery } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useRecordings() {
  return useQuery('getRecordings', () => axios.get(ENDPOINTS.recordings, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
