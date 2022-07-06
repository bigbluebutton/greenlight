import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useVerifyToken(token) {
  const resetPwd = (data) => axios.post('/reset_password/verify.json', data);
  const navigate = useNavigate();
  const mutation = useMutation(
    resetPwd,
    { // Mutation config.
      onError: (error) => { console.error('Error:', error.message); navigate('/'); },
      onSuccess: () => { console.info('Password changed.'); },
    },
  );
  const verify = () => mutation.mutate({ user: { token } });
  return { verify, ...mutation };
}
