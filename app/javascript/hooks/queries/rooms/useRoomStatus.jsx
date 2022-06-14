import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoomStatus(friendlyId, name, accessCode) {
  return useQuery(
    ['getRoomStatus', name],
    () => axios.get(`/api/v1/meetings/${friendlyId}/status.json`, {
      params: {
        name,
        access_code: accessCode,
      },
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    }).then((resp) => {
      const response = resp.data.data;
      if (response.status) {
        window.location.replace(response.joinUrl);
      }
    }),
    {
      enabled: false,
      retry: false,
    },
  );
}
