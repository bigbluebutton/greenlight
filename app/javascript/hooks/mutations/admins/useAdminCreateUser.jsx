import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useAdminCreateUser({ closeModal }) {
  const queryClient = useQueryClient();

  const addInferredLanguage = (data) => {
    let language = window.navigator.userLanguage || window.navigator.language;
    data.language = language.match(/^[a-z]{2,}/)?.at(0);
    return data
  };

  return useMutation(
    (data) => axios.post('/admin/users.json', data),
    {
      onMutate: addInferredLanguage,
      onSuccess: () => {
        closeModal();
        queryClient.invalidateQueries('getAdminUsers');
      },
      onError: (error) => {
        console.error('Error:', error.message);
      },
    },
  );
}
