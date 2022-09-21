import toast from 'react-hot-toast';
import { useMutation } from 'react-query';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useRoomStatus(friendlyId) {
  const { t } = useTranslation();

  return useMutation(
    (data) => axios.post(`/meetings/${friendlyId}/status.json`, data).then((resp) => resp.data.data),
    {
      onSuccess: ({ joinUrl }) => {
        if (joinUrl) {
          toast.loading(t('toast.success.joining_meeting'));
          window.location.replace(joinUrl);
        }
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
