import { useQuery, useQueryClient } from 'react-query';

import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useRecordingsReSync() {
  const queryClient = useQueryClient();

  return useQuery('getRecordingsResync', () => axios.get(ENDPOINTS.recordings_resync, {
  }).then(() => queryClient.invalidateQueries('getRecordings')), {
    enabled: false,
  });
}
