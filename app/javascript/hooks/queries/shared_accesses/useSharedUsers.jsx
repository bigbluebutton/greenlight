import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSharedUsers(friendlyId, input) {
  const params = {
    search: input,
  };
  return useQuery(
    ['getSharedUsers', { ...params }],
    () => axios.get(`/shared_accesses/${friendlyId}.json`, { params }).then((resp) => resp.data.data),
    {
      keepPreviousData: true,
    },
  );
}
