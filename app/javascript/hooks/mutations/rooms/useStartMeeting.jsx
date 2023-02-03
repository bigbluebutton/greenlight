import { useMutation } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useStartMeeting(friendlyId) {
  const { t } = useTranslation();

  return useMutation(
    () => axios.post(`meetings/${friendlyId}/start.json`).then((resp) => resp.data.data),
    {
      onSuccess: (joinUrl) => {
        window.location.href = joinUrl;
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
