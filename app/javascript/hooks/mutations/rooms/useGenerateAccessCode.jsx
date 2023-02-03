import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useGenerateAccessCode(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/rooms/${friendlyId}/generate_access_code.json`, { bbb_role: data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAccessCodes');
        toast.success(t('toast.success.access_code_generated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
