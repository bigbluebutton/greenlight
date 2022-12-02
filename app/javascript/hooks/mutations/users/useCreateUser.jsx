import { useMutation, useQueryClient } from 'react-query';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';
import getLanguage from '../../../helpers/Language';

export default function useCreateUser() {
  const { t } = useTranslation();
  const createUser = (data) => axios.post('/users.json', data);
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location');
  const inviteToken = searchParams.get('inviteToken');

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
        } else if (err.response.data.errors === 'EmailAlreadyExists') {
          toast.error(t('toast.error.users.email_exists'));
        } else {
          toast.error(t('toast.error.problem_completing_action'));
        }
      },
    },
  );
  const onSubmit = (user, token) => {
    const userData = { ...user, language: getLanguage(), invite_token: inviteToken };
    return mutation.mutateAsync({ user: userData, token }).catch(/* Prevents the promise exception from bubbling */() => { });
  };
  return { onSubmit, ...mutation };
}
