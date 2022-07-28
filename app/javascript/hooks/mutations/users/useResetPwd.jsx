import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useResetPwd() {
  const navigate = useNavigate();

  return useMutation(
    (user) => axios.post('/reset_password/reset.json', { user }),
    {
      onSuccess: (data) => {
        console.info(data);
        navigate('/signin');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
        navigate('/');
      },
    },
  );
}
