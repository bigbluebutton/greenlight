import toast from 'react-hot-toast';
import { useMutation } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateActivation(email) {
  const createActivation = (data) => axios.post(ENDPOINTS.createActivation, data);
  const mutation = useMutation(
    createActivation,
    { // Mutation config.
      mutationKey: ENDPOINTS.createActivation,
      onError: (error) => {
        console.error('Error:', error.message);
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      onSuccess: (data) => {
        console.info(data);
        toast.success('Verification sent.');
      },
    },
  );
  const onClick = () => mutation.mutateAsync({ user: { email } }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onClick, ...mutation };
}
