import React from 'react';
import { useTranslation } from 'react-i18next';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import SettingsRow from '../SettingsRow';

export default function Settings() {
  const { t } = useTranslation();
  const { data: siteSettings } = useSiteSettings(['ShareRooms', 'PreuploadPresentation']);

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
    </>
  );
}
