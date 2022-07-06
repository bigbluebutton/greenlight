import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useCreateResetPwd() {
  const createResetPwd = (data) => axios.post('/reset_password.json', data);
  const navigate = useNavigate();
  const mutation = useMutation(
    createResetPwd,
    { // Mutation config.
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
