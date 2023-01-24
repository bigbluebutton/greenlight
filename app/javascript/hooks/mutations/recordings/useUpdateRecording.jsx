import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUpdateRecording(recordId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (recordingData) => axios.put(`/recordings/${recordId}.json`, recordingData),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getRecordings']);
        queryClient.invalidateQueries(['getRoomRecordings']);
        queryClient.invalidateQueries('getServerRecordings');
        toast.success(t('toast.success.recording.recording_name_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
