import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useAdminCreateUser({ onSettled }) {
  const queryClient = useQueryClient();

  const addInferredLanguage = (data) => {
    const options = data;
    const language = window.navigator.userLanguage || window.navigator.language;
    options.language = language.match(/^[a-z]{2,}/)?.at(0);

    return options;
  };

  return useMutation(
    (user) => axios.post('/users.json', { user }),
    {
      onMutate: addInferredLanguage,
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
        toast.success('User was created');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
      onSettled,
    },
  );
}
