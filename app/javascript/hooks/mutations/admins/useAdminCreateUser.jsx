import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useAdminCreateUser({ onSettled }) {
  const queryClient = useQueryClient();

  const addInferredLanguage = (data) => {
    const options = data;
    const language = window.navigator.userLanguage || window.navigator.language;
    options.language = language.match(/^[a-z]{2,}/)?.at(0);

    return options;
  };

  return useMutation(
    (data) => axios.post('/admin/users.json', data),
    {
      onMutate: addInferredLanguage,
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
      onSettled,
    },
  );
}
