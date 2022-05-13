import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoomStatus(friendlyId, name) {
  return useQuery(
    ['getRoomStatus', name],
    () => axios.get(`/api/v1/rooms/${friendlyId}/status.json`, {
      params: {
        name,
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
    },
  );
}
