import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useInstantMeeting() {
  const { t } = useTranslation();

  return useMutation(
    (instantRoom) => axios.post('/instant_rooms.json', instantRoom).then((resp) => resp.data.data),
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
