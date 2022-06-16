import { useMutation } from 'react-query';
import { useNavigate, useParams } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useVerifyReset(callback) {
  const { token } = useParams();
  const resetPwd = (data) => axios.post(ENDPOINTS.verify_token, data);
  const navigate = useNavigate();
  const mutation = useMutation(
    resetPwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.verify_token,
      onError: (error) => { console.error('Error:', error.message); navigate('/'); },
      onSuccess: ({ data: { data: { refresh_token: refreshToken } } }) => {
        console.info('Refresh token:', refreshToken);
        callback(refreshToken);
      },
    },
  );
  const verify = () => mutation.mutate({ user: { token } });
  return { verify, ...mutation };
}
