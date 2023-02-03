import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useDeleteBrandingImage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete('/admin/site_settings.json'),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getSiteSettings', 'BrandingImage']);
        queryClient.invalidateQueries('getSiteSettings');
        toast.success(t('toast.success.site_settings.site_setting_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
