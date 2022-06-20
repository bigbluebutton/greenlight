import { useMutation } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useChangePwd() {
  const changePwd = (data) => axios.post(ENDPOINTS.changePassword, data);

  const mutation = useMutation(
    changePwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.changePassword,
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: () => {
        console.info('Password updated successfully.');
      },
    },
  );
  const onSubmit = (user) => mutation.mutateAsync({ user }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
