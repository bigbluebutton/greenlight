import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useShareableUsers(friendlyId, input, page) {
  const params = {
    search: input,
    page,
  };

  return useQuery(
    ['getShareableUsers', { ...params }],
    () => axios.get(`/shared_accesses/${friendlyId}/shareable_users.json`, { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
