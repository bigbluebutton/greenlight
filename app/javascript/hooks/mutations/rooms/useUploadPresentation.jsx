import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useUploadPresentation(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    const formData = new FormData();
    formData.append('room[presentation]', data);
    return axios.patch(`/rooms/${friendlyId}.json`, formData);
  };

  const mutation = useMutation(uploadPresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries(['getRoom', { friendlyId }]);
      toast.success(t('toast.success.room.presentation_updated'));
    },
    onError: () => {
      toast.error(t('toast.error.problem_completing_action'));
    },
  });

  const onSubmit = async (data) => {
    await mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
