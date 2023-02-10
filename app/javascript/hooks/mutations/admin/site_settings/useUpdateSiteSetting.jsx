import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';
import { fileValidation, handleError } from '../../../../helpers/FileValidationHelper';

export default function useUpdateSiteSetting(name) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    let settings;

    if (name === 'BrandingImage') {
      fileValidation(data, 'image');
      settings = new FormData();
      settings.append('site_setting[value]', data);
    } else {
      settings = data;
    }

    return axios.patch(`/admin/site_settings/${name}.json`, settings);
  };

  const handleSuccess = () => {
    switch (name) {
      case 'PrimaryColor':
        // Prevents 2 toasts from showing up when updating the primary color - which also updates the lighten color
        break;
      case 'PrimaryColorLight':
        toast.success(t('toast.success.site_settings.brand_color_updated'));
        break;
      case 'BrandingImage':
        toast.success(t('toast.success.site_settings.brand_image_updated'));
        break;
      case 'PrivacyPolicy':
        toast.success(t('toast.success.site_settings.privacy_policy_updated'));
        break;
      case 'TermsOfService':
        toast.success(t('toast.success.site_settings.terms_of_service_updated'));
        break;
      default:
        toast.success(t('toast.success.site_settings.site_setting_updated'));
    }
  };

  return useMutation(
    uploadPresentation,
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['getSiteSettings', name]);
        queryClient.invalidateQueries('getSiteSettings');
        handleSuccess();
      },
      onError: (error) => {
        handleError(error, t, toast);
      },
    },
  );
}
