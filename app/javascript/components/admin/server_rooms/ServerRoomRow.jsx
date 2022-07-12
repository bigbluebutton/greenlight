import React from 'react';
import { CursorClickIcon, DotsVerticalIcon, TrashIcon } from '@heroicons/react/outline';
import { Dropdown, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

export default function ServerRoomRow({ room }) {
  console.log();
  return (
    <tr className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> {room.name} </span>
          <span> Ended: </span>
        </Stack>
      </td>
      <td className="border-0"> { room.owner }</td>
      <td className="border-0"> { room.friendly_id } </td>
      <td className="border-0"> { room.participants ? room.participants : '-' } </td>
      <td className="border-0"> { room.status } </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={DotsVerticalIcon} />
          <Dropdown.Menu>
            <Dropdown.Item as={Link} to={`/rooms/${room.friendly_id}`}><CursorClickIcon className="hi-s" /> View</Dropdown.Item>
            <Dropdown.Item><TrashIcon className="hi-s" /> Delete</Dropdown.Item>
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  );
}

ServerRoomRow.propTypes = {
  room: PropTypes.shape({
    name: PropTypes.string.isRequired,
    owner: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    status: PropTypes.string.isRequired,
    participants: PropTypes.number,
  }).isRequired,
};
