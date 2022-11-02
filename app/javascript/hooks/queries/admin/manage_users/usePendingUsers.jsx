import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function usePendingUsers(input, page) {
  const params = {
    search: input,
    page,
  };

  return useQuery(
    ['getPendingUsers', { ...params }],
    () => axios.get('/admin/users/pending.json', { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
