import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import axios from '../../../../helpers/Axios';

export default function useRoles(search, enabled = true) {
  const [searchParams] = useSearchParams();

  const params = {
    'sort[column]': searchParams.get('sort[column]'),
    'sort[direction]': searchParams.get('sort[direction]'),
    search,
  };

  return useQuery(
    ['getRoles', { ...params }],
    () => axios.get('/admin/roles.json', { params }).then((resp) => resp.data.data),
    { enabled },
  );
}
