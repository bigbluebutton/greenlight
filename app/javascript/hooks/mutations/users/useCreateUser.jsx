import { useMutation, useQueryClient } from 'react-query';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';
import getLanguage from '../../../helpers/Language';

export default function useCreateUser() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location');
  const inviteToken = searchParams.get('inviteToken') || '';

  return useMutation(
    ({ user, token }) => axios.post('/users.json', { user: { language: getLanguage(), invite_token: inviteToken, ...user }, token })
      .then((resp) => resp.data.data),
    {
      onSuccess: (response) => {
        queryClient.invalidateQueries('useSessions');

        // if the current user does NOT have the CreateRoom permission, then do not re-direct to rooms page
        if (!response.verified) {
          navigate(`/verify?id=${response.id}`);
        } else if (redirect) {
          navigate(redirect);
        } else if (response.permissions.CreateRoom === 'false') {
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
}
