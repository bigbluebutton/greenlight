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
      throw new Error('fileSizeTooLarge');
    } else if (!image.type.match(SUPPORTED_FORMATS)) {
      throw new Error('fileTypeNotSupported');
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

  const handleError = (error) => {
    switch (error.message) {
      case 'fileSizeTooLarge':
        toast.error(t('toast.error.file_size_too_large'));
        break;
      case 'fileTypeNotSupported':
        toast.error(t('toast.error.file_type_not_supported'));
        break;
      default:
        toast.error(t('toast.error.problem_completing_action'));
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
        handleError(error);
      },
    },
  );
}
