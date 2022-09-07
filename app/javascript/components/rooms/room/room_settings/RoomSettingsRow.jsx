import React, { useMemo } from 'react';
import PropTypes from 'prop-types';

export default function RoomSettingsRow({
  settingName, config, value, description, updateMutation: useUpdateAPI,
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

  //  TODO: Refactor this to use react-hook-form & react-bootstrap.
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
          disabled={updateAPI.isLoading || config === 'true'}
        />
      </div>
    </div>
  );
}

RoomSettingsRow.defaultProps = {
  config: 'false',
};

RoomSettingsRow.propTypes = {
  settingName: PropTypes.string.isRequired,
  updateMutation: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  config: PropTypes.string,
  description: PropTypes.string.isRequired,
};
