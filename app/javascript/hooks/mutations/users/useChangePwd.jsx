import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useChangePwd() {
  return useMutation(
    (user) => axios.post('/users/change_password.json', { user }),
    {
      onSuccess: () => {
        toast.success('Password updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
