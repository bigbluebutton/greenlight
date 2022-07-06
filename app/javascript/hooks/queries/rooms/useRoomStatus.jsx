import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomStatus(friendlyId, name, accessCode) {
  const params = {
    name,
    access_code: accessCode,
  };
  return useQuery(
    ['getRoomStatus', name],
    () => axios.get(`/meetings/${friendlyId}/status.json`, { params }).then((resp) => {
      const response = resp.data.data;
      if (response.status) {
        window.location.replace(response.joinUrl);
      }
    }),
    { enabled: false, retry: false },
  );
}
