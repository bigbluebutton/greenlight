import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function useCreateActivationLink(id) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  return useMutation(
    () => axios.post('/verify_account.json', { user: { id } }),
    {
      onSuccess: () => {
        toast.success(t('toast.success.user.activation_email_sent'));
        navigate('/');
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
