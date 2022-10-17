import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRecordingsCount() {
  return useQuery(
    'getRecordingsCount',
    () => axios.get('/recordings/recordings_count.json').then((resp) => resp.data.data),
    {
      keepPreviousData: true,
    },
  );
}
