import { useMutation } from 'react-query';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateActivation(email) {
  const createActivation = (data) => axios.post(ENDPOINTS.createActivation, data);
  const mutation = useMutation(
    createActivation,
    { // Mutation config.
      mutationKey: ENDPOINTS.createActivation,
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: (data) => {
        console.info(data);
      },
    },
  );
  const onClick = () => mutation.mutateAsync({ user: { email } }).catch(/* Prevents the promise exception from bubbling */() => { });
  return { onClick, ...mutation };
}
