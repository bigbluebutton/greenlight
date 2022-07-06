import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useAccessCodes(friendlyId) {
  return useQuery(
    'getAccessCodes',
    () => axios.get(`/rooms/${friendlyId}/access_codes.json`).then((resp) => resp.data.data),
  );
}
