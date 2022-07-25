import React from 'react';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import useUpdateRoomSetting from '../../hooks/mutations/room_settings/useUpdateRoomSetting';

export default function RoomSettingsRow(props) {
  const {
    settingId, value, description,
  } = props;
  const { friendlyId } = useParams();
  const updateRoomSetting = useUpdateRoomSetting(friendlyId);

  return (
    <div className="room-settings-row text-muted py-3 d-flex">
      <label className="form-check-label me-auto" htmlFor={settingId}>
        { description }
      </label>
      <div className="form-switch">
        <input
          className="form-check-input text-brand fs-5"
          type="checkbox"
          id={settingId}
          defaultChecked={value}
          onClick={(event) => {
            updateRoomSetting.mutate({ settingName: settingId, settingValue: event.target.checked });
          }}
        />
      </div>
    </div>
  );
}

RoomSettingsRow.propTypes = {
  settingId: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]).isRequired,
  description: PropTypes.string.isRequired,
};
