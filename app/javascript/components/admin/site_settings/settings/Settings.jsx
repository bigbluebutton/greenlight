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
import { useTranslation } from 'react-i18next';
import { Dropdown } from 'react-bootstrap';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import SettingsRow from '../SettingsRow';
import SettingSelect from './SettingSelect';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function Settings() {
  const { t } = useTranslation();
  const { data: siteSettings, isLoading } = useSiteSettings(['ShareRooms', 'PreuploadPresentation', 'DefaultRecordingVisibility']);
  const updateDefaultRecordingVisibility = useUpdateSiteSetting('DefaultRecordingVisibility');

  if (isLoading) return null;

  return (
    <>
      <SettingsRow
        name="ShareRooms"
        title={t('admin.site_settings.settings.allow_users_to_share_rooms')}
        description={(
          <p className="text-muted">
            { t('admin.site_settings.settings.allow_users_to_share_rooms_description') }
          </p>
      )}
        value={siteSettings?.ShareRooms}
      />
      <SettingsRow
        name="PreuploadPresentation"
        title={t('admin.site_settings.settings.allow_users_to_preupload_presentation')}
        description={(
          <p className="text-muted">
            {t('admin.site_settings.settings.allow_users_to_preupload_presentation_description')}
          </p>
      )}
        value={siteSettings?.PreuploadPresentation}
      />

      <SettingSelect
        defaultValue={siteSettings?.DefaultRecordingVisibility}
        title={t('admin.site_settings.settings.default_visibility')}
        description={t('admin.site_settings.settings.default_visibility_description')}
      >
        <Dropdown.Item key="Public/Protected" value="Public/Protected" onClick={() => updateDefaultRecordingVisibility.mutate({ value: 'Public/Protected' })}>
          {t('recording.published')}
        </Dropdown.Item>
        <Dropdown.Item key="Public" value="Public" onClick={() => updateDefaultRecordingVisibility.mutate({ value: 'Public' })}>
          {t('recording.unpublished')}
        </Dropdown.Item>
        <Dropdown.Item key="Protected" value="Protected" onClick={() => updateDefaultRecordingVisibility.mutate({ value: 'Protected' })}>
          {t('recording.published')}
        </Dropdown.Item>
        <Dropdown.Item key="Published" value="Published" onClick={() => updateDefaultRecordingVisibility.mutate({ value: 'Published' })}>
          {t('recording.published')}
        </Dropdown.Item>
        <Dropdown.Item key="Unpublished" value="Unpublished" onClick={() => updateDefaultRecordingVisibility.mutate({ value: 'Unpublished' })}>
          {t('recording.unpublished')}
        </Dropdown.Item>
      </SettingSelect>
    </>
  );
}
