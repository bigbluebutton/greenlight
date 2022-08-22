import toast from 'react-hot-toast';
import { useMutation } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomStatus(friendlyId) {
  return useMutation(
    (data) => axios.post(`/meetings/${friendlyId}/status.json`, data).then((resp) => resp.data.data),
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
    },
  );
}
