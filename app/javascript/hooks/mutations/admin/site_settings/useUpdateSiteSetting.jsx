import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useUpdateSiteSetting(name) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  // TODO - samuel: replace the create avatar form with this simple validation method
  const imageValidation = (image) => {
    const FILE_SIZE = 3_000_000;
    const SUPPORTED_FORMATS = 'image/jpeg|image/png|image/svg';

    if (image.size > FILE_SIZE) {
      throw new Error(t('toast.error.file_type_not_supported'));
    } else if (!image.type.match(SUPPORTED_FORMATS)) {
      throw new Error(t('toast.error.file_size_too_large'));
    }
  };

  const uploadPresentation = (data) => {
    let settings;

    if (name === 'BrandingImage') {
      imageValidation(data);
      settings = new FormData();
      settings.append('site_setting[value]', data);
    } else {
      settings = data;
    }

    return axios.patch(`/admin/site_settings/${name}.json`, settings);
  };

  return useMutation(
    uploadPresentation,
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getSiteSettings', name]);
        queryClient.invalidateQueries('getSiteSettings');
        // Prevents 2 toasts from showing up when updating the primary color - which also updates the lighten color
        return name !== 'PrimaryColor' && toast.success(t('toast.success.site_settings.site_setting_updated'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
