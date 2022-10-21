import { useMutation, useQueryClient } from 'react-query';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';
import {useTranslation} from "react-i18next";

export default function useCreateUser() {
  const { t } = useTranslation();
  const createUser = (data) => axios.post('/users.json', data);
  const inferUserLang = () => {
    const language = window.navigator.userLanguage || window.navigator.language;
    return language.match(/^[a-z]{2,}/)?.at(0);
  };
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location');
  const invite_token = searchParams.get('invite_token');

  const mutation = useMutation(
    createUser,
    { // Mutation config.
      onSuccess: (response) => {
        queryClient.invalidateQueries('useSessions');
        // if the current user does NOT have the CreateRoom permission, then do not re-direct to rooms page
        if (redirect) {
          navigate(redirect);
        } else if (response.data.data.permissions.CreateRoom === 'false') {
          navigate('/home');
        } else {
          navigate('/rooms');
        }
      },
      onError: (err) => {
        if (err.response.data.errors === 'InviteInvalid') {
          toast.error(t('toast.error.users.invalid_invite'));
        } else {
          toast.error(t('toast.error.problem_completing_action'));
        }
      },
    },
  );
  const onSubmit = (user, token) => {
    const userData = { ...user, language: inferUserLang(), invite_token: invite_token };
    return mutation.mutateAsync({ user: userData, token }).catch(/* Prevents the promise exception from bubbling */() => { });
  };
  return { onSubmit, ...mutation };
}
