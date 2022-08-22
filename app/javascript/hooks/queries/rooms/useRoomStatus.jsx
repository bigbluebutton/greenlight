import toast from 'react-hot-toast';
import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomStatus(friendlyId, name, accessCode) {
  const params = {
    name,
    access_code: accessCode,
  };
  return useQuery(
    ['getRoomStatus', name],
    () => axios.get(`/meetings/${friendlyId}/status.json`, { params }).then((resp) => resp.data.data),
    {
      onSuccess: ({ joinUrl }) => {
        if (joinUrl) {
          toast.loading('Joining the meeting...');
          window.location.replace(joinUrl);
        }
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      enabled: false,
      retry: false,
      cacheTime: 0, // No caching.
    },
  );
}
