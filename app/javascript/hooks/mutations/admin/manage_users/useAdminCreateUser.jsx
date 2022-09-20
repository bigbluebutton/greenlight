import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useAdminCreateUser({ onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const addInferredLanguage = (data) => {
    const options = data;
    const language = window.navigator.userLanguage || window.navigator.language;
    options.language = language.match(/^[a-z]{2,}/)?.at(0);

    return options;
  };

  return useMutation(
    (user) => axios.post('/users.json', { user }),
    {
      onMutate: addInferredLanguage,
      onSuccess: () => {
        queryClient.invalidateQueries('getAdminUsers');
        toast.success(t('toast.success.user_created'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
      onSettled,
    },
  );
}
