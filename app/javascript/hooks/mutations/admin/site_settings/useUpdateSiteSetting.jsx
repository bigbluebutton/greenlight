// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
    let headers = { 'Content-Type': 'application/json' };

    if (name === 'BrandingImage') {
      fileValidation(data, 'image');
      settings = new FormData();
      settings.append('site_setting[value]', data);
      headers = { 'Content-Type': 'multipart/form-data' };
    } else {
      settings = data;
    }

    return axios.patch(`/admin/site_settings/${name}.json`, settings, { headers });
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
      case 'AccessibilityStatement':
        toast.success(t('toast.success.site_settings.accessibility_updated'));
        break;
      case 'HelpCenter':
        toast.success(t('toast.success.site_settings.helpcenter_updated'));
        break;
      case 'TermsOfService':
        toast.success(t('toast.success.site_settings.terms_of_service_updated'));
        break;
      case 'Maintenance':
        toast.success(t('toast.success.site_settings.maintenance_updated'));
        break;
      case 'AllowedDomains':
        toast.success(t('toast.success.site_settings.allowed_domains_signup_updated'));
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
        if (error.response.data.errors.includes('Image MalwareDetected')) {
          toast.error(t('toast.error.malware_detected'));
        } else {
          handleError(error, t, toast);
        }
      },
    },
  );
}
