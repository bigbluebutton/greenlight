import React from 'react';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import useUpdateRoomSetting from '../../hooks/mutations/room_settings/useUpdateRoomSetting';

export default function RoomSettingsRow(props) {
  const {
    settingId, value, description,
  } = props;
  const { friendlyId } = useParams();
  const { handleUpdateRoomSetting } = useUpdateRoomSetting(friendlyId);

  return (
    <span className="text-muted">
      <label className="form-check-label me-5" htmlFor={settingId}>
        { description }
        <div className="form-switch d-inline-block ms-5">
          <input
            className="form-check-input text-primary"
            type="checkbox"
            id={settingId}
            defaultChecked={value}
            onClick={(event) => {
              handleUpdateRoomSetting({ settingName: settingId, settingValue: event.target.checked });
            }}
          />
        </div>
      </label>
    </span>
  );
}

RoomSettingsRow.propTypes = {
  settingId: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]).isRequired,
  description: PropTypes.string.isRequired,
};
