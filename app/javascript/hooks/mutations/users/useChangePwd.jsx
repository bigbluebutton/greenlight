import { useMutation } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useChangePwd(userId) {
  const changePwd = (data) => axios.post(ENDPOINTS.changePassword(userId), data);

  const mutation = useMutation(
    changePwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.changePassword(userId),
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: () => {
        console.info('Password updated successfully.');
      },
    },
  );
  const onSubmit = (user) => mutation.mutateAsync({ user }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
