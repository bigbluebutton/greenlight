import React from 'react';
import useUpdateRoomSetting from "../../hooks/mutations/room_settings/useUpdateRoomSetting";
import {useParams} from "react-router-dom";

export default function RoomSettingsRow(props) {
  const { settingId, value, description } = props
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
