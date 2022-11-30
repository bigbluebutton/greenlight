import toast from 'react-hot-toast';
import { useMutation } from 'react-query';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useJoinInstantMeeting(friendlyId) {
  const { t } = useTranslation();

  return useMutation(
    (data) => axios.post(`/instant_rooms/${friendlyId}/join.json`, data).then((resp) => resp.data.data),
    {
      onSuccess: (joinUrl) => {
        toast.loading(t('toast.success.room.joining_meeting'));
        window.location.replace(joinUrl);
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
