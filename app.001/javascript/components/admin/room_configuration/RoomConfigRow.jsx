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
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SettingSelect from '../site_settings/settings/SettingSelect';
import useUpdateRoomConfig from '../../../hooks/mutations/admin/room_configuration/useUpdateRoomConfig';

export default function RoomConfigRow({
  value, title, subtitle, settingName,
}) {
  const { t } = useTranslation();
  const useUpdateRoom = useUpdateRoomConfig(settingName);

  return (
    <SettingSelect
      defaultValue={value}
      title={title}
      description={subtitle}
    >
      <Dropdown.Item value="true" onClick={() => useUpdateRoom.mutate({ value: 'true' })}>
        {t('admin.room_configuration.enabled')}
      </Dropdown.Item>
      <Dropdown.Item value="default_enabled" onClick={() => useUpdateRoom.mutate({ value: 'default_enabled' })}>
        {t('admin.room_configuration.default')}
      </Dropdown.Item>
      <Dropdown.Item value="optional" onClick={() => useUpdateRoom.mutate({ value: 'optional' })}>
        {t('admin.room_configuration.optional')}
      </Dropdown.Item>
      <Dropdown.Item value="false" onClick={() => useUpdateRoom.mutate({ value: 'false' })}>
        {t('admin.room_configuration.disabled')}
      </Dropdown.Item>
    </SettingSelect>
  );
}

RoomConfigRow.propTypes = {
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  settingName: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
};
