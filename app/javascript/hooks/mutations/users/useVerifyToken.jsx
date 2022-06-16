import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useVerifyToken(token) {
  const resetPwd = (data) => axios.post(ENDPOINTS.verify_token, data);
  const navigate = useNavigate();
  const mutation = useMutation(
    resetPwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.verify_token,
      onError: (error) => { console.error('Error:', error.message); navigate('/'); },
      onSuccess: () => { console.info('Password changed.'); },
    },
  );
  const verify = () => mutation.mutate({ user: { token } });
  return { verify, ...mutation };
}
