import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useVerifyToken() {
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post('/reset_password/verify.json', data),
    {
      onSuccess: () => {
        toast.success('Password updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
        navigate('/');
      },
    },
  );
}
