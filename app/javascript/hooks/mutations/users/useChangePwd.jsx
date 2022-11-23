import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useChangePwd() {
  const { t } = useTranslation();

  return useMutation(
    (user) => axios.post('/users/change_password.json', { user }),
    {
      onSuccess: () => {
        toast.success(t('toast.success.user.password_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
