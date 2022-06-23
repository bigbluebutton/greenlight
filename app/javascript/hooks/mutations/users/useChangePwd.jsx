import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useChangePwd() {
  const changePwd = (data) => axios.post(ENDPOINTS.changePassword, data);

  const mutation = useMutation(
    changePwd,
    { // Mutation config.
      mutationKey: ENDPOINTS.changePassword,
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        toast.success('Password updated');
      },
    },
  );
  const onSubmit = (user) => mutation.mutateAsync({ user }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onSubmit, ...mutation };
}
