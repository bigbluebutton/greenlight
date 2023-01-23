import React from 'react';
import { Dropdown, Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import RegistrationForm from './forms/RegistrationForm';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import SettingsRow from '../SettingsRow';
import useEnv from '../../../../hooks/queries/env/useEnv';
import SettingSelect from '../settings/SettingSelect';
import useRoles from '../../../../hooks/queries/admin/roles/useRoles';

export default function Registration() {
  const { t } = useTranslation();
  const { data: env } = useEnv();
  const { data: siteSettings } = useSiteSettings(['RoleMapping', 'DefaultRole', 'ResyncOnLogin', 'RegistrationMethod']);
  const { data: roles } = useRoles();
  const updateRegistrationMethod = useUpdateSiteSetting('RegistrationMethod');
  const updateDefaultRole = useUpdateSiteSetting('DefaultRole');

  return (
    <>
      <SettingSelect
        defaultValue={siteSettings?.RegistrationMethod}
        title={t('admin.site_settings.registration.registration_method')}
        description={t('admin.site_settings.registration.registration_method_description')}
      >
        <Dropdown.Item value="open" onClick={() => updateRegistrationMethod.mutate({ value: 'open' })}>
          {t('admin.site_settings.registration.registration_methods.open')}
        </Dropdown.Item>
        <Dropdown.Item value="invite" onClick={() => updateRegistrationMethod.mutate({ value: 'invite' })}>
          {t('admin.site_settings.registration.registration_methods.invite')}
        </Dropdown.Item>
        <Dropdown.Item value="approval" onClick={() => updateRegistrationMethod.mutate({ value: 'approval' })}>
          {t('admin.site_settings.registration.registration_methods.approval')}
        </Dropdown.Item>
      </SettingSelect>

      { env?.OPENID_CONNECT && (
        <Row className="mb-3">
          <SettingsRow
            name="ResyncOnLogin"
            title={t('admin.site_settings.registration.resync_on_login')}
            description={(
              <p className="text-muted">
                { t('admin.site_settings.registration.resync_on_login_description') }
              </p>
            )}
            value={siteSettings?.ResyncOnLogin}
          />
        </Row>
      )}

      <SettingSelect
        defaultValue={siteSettings?.DefaultRole}
        title={t('admin.site_settings.registration.default_role')}
        description={t('admin.site_settings.registration.default_role_description')}
      >
        {
          roles?.map((role) => (
            <Dropdown.Item value={role.name} onClick={() => updateDefaultRole.mutate({ value: role.name })}>
              {role.name}
            </Dropdown.Item>
          ))
        }
      </SettingSelect>

      <Row className="mb-3">
        <h6> { t('admin.site_settings.registration.role_mapping_by_email') } </h6>
        <p className="text-muted"> { t('admin.site_settings.registration.role_mapping_by_email_description') } </p>
        <RegistrationForm
          mutation={() => useUpdateSiteSetting('RoleMapping')}
          value={siteSettings?.RoleMapping}
        />
      </Row>
    </>
  );
}
