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

import React, { useMemo } from 'react';
import PropTypes from 'prop-types';

export default function RoomSettingsRow({
  settingName, config, value, description, updateMutation: useUpdateAPI, disabled,
}) {
  const updateAPI = useUpdateAPI();
  const checkedValue = useMemo(() => {
    if (value === 'true' || value === 'ASK_MODERATOR') {
      return true;
    } if (value === 'false' || value === 'ALWAYS_ACCEPT') {
      return false;
    }
    return value;
  }, [value]);

  if (config === 'false') {
    return null;
  }

  //  TODO: Amir - Refactor this to use react-hook-form & react-bootstrap.
  return (
    <div className="room-settings-row text-muted py-2 d-flex">
      <label className="form-check-label me-auto" htmlFor={settingName}>
        {description}
      </label>
      <div className="form-switch">
        <input
          className="form-check-input fs-5"
          type="checkbox"
          id={settingName}
          checked={checkedValue}
          onChange={(event) => {
            updateAPI.mutate({ settingName, settingValue: event.target.checked });
          }}
          disabled={updateAPI.isLoading || config === 'true' || disabled}
        />
      </div>
    </div>
  );
}

RoomSettingsRow.defaultProps = {
  value: '',
  config: 'false',
  disabled: false,
};

RoomSettingsRow.propTypes = {
  settingName: PropTypes.string.isRequired,
  updateMutation: PropTypes.func.isRequired,
  value: PropTypes.string,
  config: PropTypes.string,
  description: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
};
