import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import axios from '../../../../helpers/Axios';

export default function useServerRecordings(search, page) {
  const [searchParams] = useSearchParams();

  const params = {
    'sort[column]': searchParams.get('sort[column]'),
    'sort[direction]': searchParams.get('sort[direction]'),
    search,
    page,
  };

  return useQuery(
    ['getServerRecordings', { ...params }],
    () => axios.get('/admin/server_recordings.json', { params }).then((resp) => resp.data),
    {
      keepPreviousData: true,
    },
  );
}
