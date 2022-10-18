import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useMutation } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useCreateActivationLink(email) {
  const { t } = useTranslation();

  return useMutation(
    () => axios.post('/verify_account.json', { user: { email } }),
    {
      onSuccess: () => {
        toast.success(t('toast.success.user.activation_email_sent'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
