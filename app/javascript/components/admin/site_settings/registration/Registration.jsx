import React from 'react';
import { Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import RegistrationForm from './forms/RegistrationForm';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import Spinner from '../../../shared_components/utilities/Spinner';
import SettingsRow from '../SettingsRow';
import useEnv from '../../../../hooks/queries/env/useEnv';
import SettingSelect from '../settings/SettingSelect';

export default function Registration() {
  const { t } = useTranslation();
  const { isLoadingEnv, data: env } = useEnv();
  const { isLoading, data: siteSettings } = useSiteSettings(['RoleMapping', 'DefaultRole', 'ResyncOnLogin']);


  if (isLoading || isLoadingEnv) return <Spinner />;

  return (
    <>
      { env.OPENID_CONNECT && (
        <Row className="mb-3">
          <SettingsRow
            name="ResyncOnLogin"
            title={t('admin.site_settings.registration.resync_on_login')}
            description={(
              <p className="text-muted">
                { t('admin.site_settings.registration.resync_on_login_description') }
              </p>
            )}
            value={siteSettings.ResyncOnLogin}
          />
        </Row>
      )}

      <SettingSelect
        settingName="DefaultRole"
        defaultValue={siteSettings.DefaultRole}
        title={t('admin.site_settings.settings.default_role')}
        description={t('admin.site_settings.settings.default_role_description')}
      />

      <Row className="mb-3">
        <h6> { t('admin.site_settings.registration.role_mapping_by_email') } </h6>
        <p className="text-muted"> { t('admin.site_settings.registration.role_mapping_by_email_description') } </p>
        <RegistrationForm
          mutation={() => useUpdateSiteSetting('RoleMapping')}
          value={siteSettings.RoleMapping}
        />
      </Row>
    </>
  );
}
