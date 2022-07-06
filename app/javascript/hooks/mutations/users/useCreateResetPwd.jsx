import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useCreateResetPwd() {
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post('/reset_password.json', data),
    {
      onSuccess: (data) => {
        console.info(data);
        navigate('/');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );
}
