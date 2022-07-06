import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useResetPwd() {
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post('/reset_password/reset.json', data),
    {
      onSuccess: (data) => {
        console.info(data);
        navigate('/signin');
      },
      onError: (error) => {
        console.error('Error:', error.message);
        navigate('/');
      },
    },
  );
}
