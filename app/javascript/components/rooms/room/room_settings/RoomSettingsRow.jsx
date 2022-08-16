import React, { useMemo } from 'react';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import useUpdateRoomSetting from '../../../../hooks/mutations/room_settings/useUpdateRoomSetting';

export default function RoomSettingsRow({
  settingId, config, value, description,
}) {
  const { friendlyId } = useParams();
  const updateRoomSetting = useUpdateRoomSetting(friendlyId);
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

  //  TODO: Refactor this to use react-hook-form.
  return (
    <div className="room-settings-row text-muted py-3 d-flex">
      <label className="form-check-label me-auto" htmlFor={settingId}>
        {description}
      </label>
      <div className="form-switch">
        <input
          className="form-check-input fs-5"
          type="checkbox"
          id={settingId}
          defaultChecked={checkedValue}
          onClick={(event) => {
            updateRoomSetting.mutate({ settingName: settingId, settingValue: event.target.checked });
          }}
          disabled={config === 'true'}
        />
      </div>
    </div>
  );
}

RoomSettingsRow.defaultProps = {
  config: 'false',
};

RoomSettingsRow.propTypes = {
  settingId: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  config: PropTypes.string,
  description: PropTypes.string.isRequired,
};
