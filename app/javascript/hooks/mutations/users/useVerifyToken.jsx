import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useVerifyToken() {
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post('/reset_password/verify.json', data),
    {
      onError: () => {
        navigate('/');
      },
    },
  );
}
