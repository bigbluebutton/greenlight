import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';
import { fileValidation, handleError } from '../../../helpers/FileValidationHelper';

export default function useUploadPresentation(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const uploadPresentation = (presentation) => {
    fileValidation(presentation, 'presentation');
    const formData = new FormData();
    formData.append('room[presentation]', presentation);
    return axios.patch(`/rooms/${friendlyId}.json`, formData);
  };

  const mutation = useMutation(uploadPresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries(['getRoom', { friendlyId }]);
      toast.success(t('toast.success.room.presentation_updated'));
    },
    onError: (error) => {
      handleError(error, t, toast);
    },
  });

  const onSubmit = async (data) => {
    await mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
