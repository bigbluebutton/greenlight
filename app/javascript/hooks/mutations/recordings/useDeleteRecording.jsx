import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useDeleteRecording({ recordId, onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/recordings/${recordId}.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getRecordings']);
        queryClient.invalidateQueries('getRecordingsCount');
        queryClient.invalidateQueries(['getRoomRecordings']);
        queryClient.invalidateQueries('getServerRecordings');
        toast.success(t('toast.success.recording.recording_deleted'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
      onSettled,
    },
  );
}
