import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useCreateResetPwd() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  return useMutation(
    (user) => axios.post('/reset_password.json', { user }),
    {
      onSuccess: () => {
        navigate('/');
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
