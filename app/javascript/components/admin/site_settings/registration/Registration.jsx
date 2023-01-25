import React from 'react';
import { Dropdown, Row, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
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
  const updateRoleMapping = useUpdateSiteSetting('RoleMapping');

  return (
    <>
      <SettingSelect
        defaultValue={siteSettings?.RegistrationMethod}
        title={t('admin.site_settings.registration.registration_method')}
        description={t('admin.site_settings.registration.registration_method_description')}
      >
        <Dropdown.Item key="open" value="open" onClick={() => updateRegistrationMethod.mutate({ value: 'open' })}>
          {t('admin.site_settings.registration.registration_methods.open')}
        </Dropdown.Item>
        <Dropdown.Item key="invite" value="invite" onClick={() => updateRegistrationMethod.mutate({ value: 'invite' })}>
          {t('admin.site_settings.registration.registration_methods.invite')}
        </Dropdown.Item>
        <Dropdown.Item key="approval" value="approval" onClick={() => updateRegistrationMethod.mutate({ value: 'approval' })}>
          {t('admin.site_settings.registration.registration_methods.approval')}
        </Dropdown.Item>
      </SettingSelect>

      { env?.OPENID_CONNECT && (
        <Row className="mb-3">
          <SettingsRow
            name="ResyncOnLogin"
            title={t('admin.site_settings.registration.resync_on_login')}
            description={(
              <p className="text-muted mb-0">
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
            <Dropdown.Item key={role.name} value={role.name} onClick={() => updateDefaultRole.mutate({ value: role.name })}>
              {role.name}
            </Dropdown.Item>
          ))
        }
      </SettingSelect>

      <Row className="mb-3">
        <strong> { t('admin.site_settings.registration.role_mapping_by_email') } </strong>
        <p className="text-muted"> { t('admin.site_settings.registration.role_mapping_by_email_description') } </p>
        <Stack direction="horizontal">
          <input
            className="form-control"
            placeholder={t('admin.site_settings.registration.enter_role_mapping_rule')}
            defaultValue={siteSettings?.RoleMapping}
          />
          <Button
            variant="brand"
            className="ms-2"
            onClick={(e) => updateRoleMapping.mutate({ value: e.target.previousSibling.value })}
          >
            {t('update')}
          </Button>
        </Stack>
      </Row>
    </>
  );
}
