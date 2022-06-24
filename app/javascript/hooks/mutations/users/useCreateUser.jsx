import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useCreateUser() {
  const createUser = (data) => axios.post(ENDPOINTS.signup, data);
  const inferUserLang = () => {
    const language = window.navigator.userLanguage || window.navigator.language;
    return language.match(/^[a-z]{2,}/)?.at(0);
  };
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const mutation = useMutation(
    createUser,
    { // Mutation config.
      mutationKey: ENDPOINTS.signup,
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        navigate('/rooms');
      },
    },
  );
  const onSubmit = (user, token) => {
    const userData = { ...user, language: inferUserLang() };
    return mutation.mutateAsync({ user: userData, token }).catch(/* Prevents the promise exception from bubbling */() => { });
  };
  return { onSubmit, ...mutation };
}
