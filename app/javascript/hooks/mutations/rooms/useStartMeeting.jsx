import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useStartMeeting(friendlyId) {
  return useMutation(
    () => axios.post(`meetings/${friendlyId}/start.json`).then((resp) => resp.data.data),
    {
      onSuccess: (joinUrl) => {
        window.location.href = joinUrl;
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
