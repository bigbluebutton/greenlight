import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useRecordings(search) {
  const [searchParams] = useSearchParams();

  const params = {
    'sort[column]': searchParams.get('sort[column]'),
    'sort[direction]': searchParams.get('sort[direction]'),
    search,
  };

  return useQuery(['getRecordings', { ...params }], () => axios.get(ENDPOINTS.recordings, { params }).then((resp) => resp.data.data));
}
