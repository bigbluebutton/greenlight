import { useMutation, useQueryClient } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useCreateUser({ closeModal }) {
  const createUser = (data) => axios.post('/admin/users.json', data);
  const inferUserLang = () => {
    const language = window.navigator.userLanguage || window.navigator.language;
    return language.match(/^[a-z]{2,}/)?.at(0);
  };
  const queryClient = useQueryClient();
  const mutation = useMutation(
    createUser,
    { // Mutation config.
      mutationKey: '/admin/users.json',
      onError: (error) => { console.error('Error:', error.message); },
      onSuccess: () => {
        closeModal();
        queryClient.invalidateQueries('getAdminUsers');
      },
    },
  );
  const onSubmit = (user) => {
    const userData = { ...user, language: inferUserLang() };
    return mutation.mutateAsync({ user: userData }).catch(/* Prevents the promise exception from bubbling */() => { });
  };
  return { onSubmit, ...mutation };
}
