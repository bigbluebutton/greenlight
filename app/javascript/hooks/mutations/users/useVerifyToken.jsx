import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useVerifyToken(token) {
  const navigate = useNavigate();

  return useMutation(
    () => axios.post('/reset_password/verify.json', { user: { token } }),
    {
      onError: () => {
        navigate('/'); // TODO: Amir - Obsecure this as a 404 case.
      },
    },
  );
}
