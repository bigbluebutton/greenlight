import React from 'react';
import {
  EyeIcon, DotsVerticalIcon, TrashIcon, ExternalLinkIcon,
} from '@heroicons/react/outline';
import { Dropdown, Stack } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import useDeleteServerRoom from '../../../hooks/mutations/admins/server-rooms/useDeleteServerRoom';
import Modal from '../../shared/Modal';
import DeleteRoomForm from '../../forms/DeleteRoomForm';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';

export default function ServerRoomRow({ room }) {
  const { friendly_id: friendlyId } = room;
  const mutationWrapper = (args) => useDeleteServerRoom({ friendlyId, ...args });
  const { handleStartMeeting } = useStartMeeting(friendlyId);

  return (
    <tr className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> {room.name} </span>
          <span> Ended: </span>
        </Stack>
      </td>
      <td className="border-0"> {room.owner}</td>
      <td className="border-0"> {room.friendly_id} </td>
      <td className="border-0"> {room.participants ? room.participants : '-'} </td>
      <td className="border-0"> {room.status} </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={DotsVerticalIcon} />
          <Dropdown.Menu>
            { room.status === 'Active'
              ? <Dropdown.Item><ExternalLinkIcon className="hi-s text-muted" /> Join </Dropdown.Item>
              : <Dropdown.Item><ExternalLinkIcon className="hi-s text-muted" onClick={handleStartMeeting} /> Start </Dropdown.Item>}
            <Dropdown.Item as={Link} to={`/rooms/${room.friendly_id}`}><EyeIcon className="hi-s text-muted" /> View </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><TrashIcon className="hi-s text-muted" /> Delete</Dropdown.Item>}
              title="Delete Server Room"
              body={<DeleteRoomForm mutation={mutationWrapper} />}
            />
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
