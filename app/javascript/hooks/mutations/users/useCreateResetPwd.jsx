import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateResetPwd() {
  const createResetPwd = (data) => axios.post(ENDPOINTS.forget_password, data);
  const navigate = useNavigate();
  const mutation = useMutation(
    createResetPwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.forget_password,
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: (data) => {
        console.info(data);
        navigate('/');
      },
    },
  );
  const onSubmit = (user) => mutation.mutateAsync({ user }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
