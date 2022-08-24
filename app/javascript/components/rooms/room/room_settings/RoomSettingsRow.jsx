import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { Row } from 'react-bootstrap';

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
    <Row>
      <div className="room-settings-row text-muted py-3 d-flex">
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
    </Row>
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
