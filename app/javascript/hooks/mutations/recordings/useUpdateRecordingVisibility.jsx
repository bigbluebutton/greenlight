import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUpdateRecordingVisibility() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (visibilityData) => axios.post('/recordings/update_visibility.json', visibilityData),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getRecordings');
        toast.success(t('toast.success.recording.recording_visibility_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
