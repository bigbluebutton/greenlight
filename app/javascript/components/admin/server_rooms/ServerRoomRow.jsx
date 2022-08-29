import React from 'react';
import {
  EyeIcon, DotsVerticalIcon, TrashIcon, ExternalLinkIcon,
} from '@heroicons/react/outline';
import { Dropdown, Stack } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import useDeleteServerRoom from '../../../hooks/mutations/admin/server_rooms/useDeleteServerRoom';
import Modal from '../../shared_components/modals/Modal';
import DeleteRoomForm from '../../rooms/room/forms/DeleteRoomForm';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import useRoomStatus from '../../../hooks/mutations/rooms/useRoomStatus';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function ServerRoomRow({ room }) {
  const {
    friendly_id: friendlyId, name, owner, last_session: lastSession, active, participants,
  } = room;
  const mutationWrapper = (args) => useDeleteServerRoom({ friendlyId, ...args });
  const startMeeting = useStartMeeting(friendlyId);
  const currentUser = useAuth();
  const roomStatusAPI = useRoomStatus(room.friendly_id);

  // TODO - samuel: useRoomStatus will not work if room has an access code. Will need to add bypass in MeetingController
  const handleJoin = () => roomStatusAPI.mutate({ name: currentUser.name });

  const renderLastSession = () => {
    if (lastSession == null) {
      return 'No meeting yet.';
    }
    if (active) {
      return `Current Session: ${lastSession}`;
    }
    return `Last Session: ${lastSession}`;
  };

  return (
    <tr className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> {name} </span>
          <span> {renderLastSession()} </span>
        </Stack>
      </td>
      <td className="border-0"> {owner}</td>
      <td className="border-0"> {friendlyId} </td>
      <td className="border-0"> {participants || '-'} </td>
      <td className="border-0"> {active ? 'Active' : 'Not Running'} </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={DotsVerticalIcon} />
          <Dropdown.Menu>
            { room.active
              ? (
                <Dropdown.Item className="text-muted" onClick={handleJoin}>
                  <ExternalLinkIcon className="hi-s pb-1 me-1" /> Join
                </Dropdown.Item>
              )
              : (
                <Dropdown.Item className="text-muted" onClick={startMeeting.mutate}>
                  <ExternalLinkIcon className="hi-s pb-1 me-1" /> Start
                </Dropdown.Item>
              )}
            <Dropdown.Item className="text-muted" as={Link} to={`/rooms/${room.friendly_id}`}>
              <EyeIcon className="hi-s pb-1 me-1" /> View
            </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item className="text-muted"><TrashIcon className="hi-s pb-1 me-1" /> Delete</Dropdown.Item>}
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
    active: PropTypes.bool.isRequired,
    last_session: PropTypes.string,
    participants: PropTypes.number,
  }).isRequired,
};
