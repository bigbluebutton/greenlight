import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useShareAccess({ friendlyId, closeModal }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const shareAccess = (data) => {
    let sharedUsers = data.shared_users;
    if (typeof data.shared_users === 'string') {
      sharedUsers = [data.shared_users];
    }

    return axios.post('/shared_accesses.json', { friendly_id: friendlyId, shared_users: sharedUsers });
  };

  const mutation = useMutation(shareAccess, {
    onSuccess: () => {
      closeModal();
      queryClient.invalidateQueries('getSharedUsers');
      toast.success(t('toast.success.room.room_shared'));
    },
    onError: () => {
      toast.error(t('toast.error.problem_completing_action'));
    },
  });

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
