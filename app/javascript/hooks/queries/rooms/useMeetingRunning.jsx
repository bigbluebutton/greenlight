import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useMeetingRunning(friendlyId) {
  return useQuery(
    'getMeetingRunning',
     () => axios.get(`/meetings/${friendlyId}/running.json`)
      .then((resp) => resp.data.data),
  );
}
