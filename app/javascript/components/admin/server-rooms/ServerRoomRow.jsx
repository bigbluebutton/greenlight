import React from 'react';
import { DotsVerticalIcon } from '@heroicons/react/outline';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function ServerRoomRow({ room }) {
  return (
    <tr className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> { room.name } </span>
          <span> Ended: </span>
        </Stack>
      </td>
      <td className="border-0"> { room.owner }</td>
      <td className="border-0"> { room.friendly_id } </td>
      <td className="border-0"> - </td>
      <td className="border-0"> - </td>
      <td className="border-start-0">
        <DotsVerticalIcon className="hi-s text-muted" />
      </td>
    </tr>
  );
}

ServerRoomRow.propTypes = {
  room: PropTypes.shape({
    name: PropTypes.string.isRequired,
    owner: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
  }).isRequired,
};
