import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSharedUsers(friendlyId, input, setSharedUsers) {
  const params = {
    search: input,
  };
  return useQuery(
    ['getSharedUsers', input],
    () => axios.get(`/shared_accesses/${friendlyId}.json`, { params }).then((resp) => setSharedUsers(resp.data.data)),
  );
}
