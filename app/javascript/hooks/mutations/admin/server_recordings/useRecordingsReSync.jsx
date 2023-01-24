import { t } from 'i18next';
import toast from 'react-hot-toast';
import { useMutation, useQueryClient } from 'react-query';

import axios from '../../../../helpers/Axios';

export default function useRecordingsReSync(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.get(`/admin/server_rooms/${friendlyId}/resync.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getServerRecordings');
        queryClient.invalidateQueries(['getRoomRecordings', { friendlyId }]);
        queryClient.invalidateQueries(['getRecordings']);
        toast.success(t('toast.success.room.recordings_synced'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
