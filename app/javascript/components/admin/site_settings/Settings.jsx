import React from 'react';
import useSiteSettings from '../../../hooks/queries/admin/site_settings/useSiteSettings';
import Spinner from '../../shared/stylings/Spinner';
import SiteSettingsRow from './SiteSettingsRow';

export default function Settings() {
  const { isLoading, data: siteSettings } = useSiteSettings();

  if (isLoading) return <Spinner />;

  return (
    <SiteSettingsRow
      name="ShareRooms"
      title="Allow Users to Share Rooms"
      description={(
        <p className="text-muted">
          Setting to disbaled will remove the button from the room options <br />
          dropdown, preventing users from sharing rooms
        </p>
    )}
      value={siteSettings.ShareRooms}

    />

  );
}
