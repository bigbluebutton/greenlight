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
  const { data: siteSettings } = useSiteSettings(['RoleMapping', 'DefaultRole', 'ResyncOnLogin', 'RegistrationMethod', 'SpecificEmailDomainSignUp']);
  const { data: roles } = useRoles();
  const updateRegistrationMethod = useUpdateSiteSetting('RegistrationMethod');
  const updateDefaultRole = useUpdateSiteSetting('DefaultRole');
  const updateRoleMapping = useUpdateSiteSetting('RoleMapping');
  const updateDomainSignUp = useUpdateSiteSetting('SpecificEmailDomainSignUp');

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

      { env?.EXTERNAL_AUTH && (
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

      <Row className="mb-3">
        <strong> {t('admin.site_settings.registration.specific_email_domain_signup')} </strong>
        <p className="text-muted">{t('admin.site_settings.registration.specific_email_domain_signup_description')}</p>
        <Stack direction="horizontal">
          <input
            className="form-control"
            // TODO add proper placeholder and defultValue
            placeholder={t('admin.site_settings.registration.enter_domain_signup_rule')}
          />
          <Button
            variant="brand"
            className="ms-2"
            onClick={(e) => updateDomainSignUp.mutate({ value: e.target.previousSibling.value })}
          >
            {t('update')}
          </Button>
        </Stack>
      </Row>
    </>
  );
}
