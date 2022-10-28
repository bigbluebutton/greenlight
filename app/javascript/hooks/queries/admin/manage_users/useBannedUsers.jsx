import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useBannedUsers(input, page) {
  const params = {
    search: input,
    page,
  };

  return useQuery(
    ['getBannedUsers', { ...params }],
    () => axios.get('/admin/users/banned_users.json', { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
