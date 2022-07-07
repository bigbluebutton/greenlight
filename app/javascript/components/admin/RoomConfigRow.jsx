import React from 'react';
import Form from 'react-bootstrap/Form';
import PropTypes from 'prop-types';
import {
  Row, Stack,
} from 'react-bootstrap';
import useUpdateRoomSetting from '../../hooks/mutations/admins/useUpdateRoomSetting';

export default function RoomConfigRow({ title, subtitle }) {
  const updateRoomSetting = useUpdateRoomSetting();
  return (
    <Row>
      <Stack direction="horizontal">
        <Stack>
          <strong> {title} </strong>
          <span className="text-muted"> {subtitle} </span>
        </Stack>
        {/* TODO: Refactor this. */}
        <Form.Select
          className="visibility-dropdown"
          onChange={(event) => {
            updateRoomSetting.mutate({ setting_name: 'muteOnStart', value: event.target.value });
          }}
        >
          <option value="false">Disabled</option>
          <option value="optional">Optional</option>
          <option value="true">Enabled</option>
        </Form.Select>
      </Stack>
    </Row>
  );
}

RoomConfigRow.propTypes = {
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
};
