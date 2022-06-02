import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy } from '@fortawesome/free-regular-svg-icons';
import { faChalkboardUser } from '@fortawesome/free-solid-svg-icons';
import Spinner from '../shared/stylings/Spinner';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';

export default function RoomCard({ room }) {
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(room.friendly_id); }, [room.friendly_id]);
  const { handleStartMeeting, isLoading: startMeetingIsLoading } = useStartMeeting(room.friendly_id);

  function copyInvite() {
    navigator.clipboard.writeText(`${window.location}/${room.friendly_id}/join`);
  }

  return (
    <Card id="room-card" className="shadow-sm border-0">
      <Card.Body className="pb-0" onClick={handleClick}>
        <div className="room-icon-square rounded-3">
          <FontAwesomeIcon icon={faChalkboardUser} className="fa-2x text-primary pt-4 d-block mx-auto" />
        </div>
        <Stack className="my-4">
          <Card.Title className="mb-0"> { room.name } </Card.Title>
          <span className="text-muted"> { room.created_at } </span>
        </Stack>
      </Card.Body>
      <Card.Footer className="bg-white">
        <Button
          variant="font-awesome"
          className="fs-4 text-muted"
          onClick={() => copyInvite}
        >
          <FontAwesomeIcon icon={faCopy} />
        </Button>
        <Button variant="primary-light" className="float-end" onClick={handleStartMeeting} disabled={startMeetingIsLoading}>
          Start {' '}
          {startMeetingIsLoading && <Spinner />}
        </Button>
      </Card.Footer>
    </Card>
  );
}

RoomCard.propTypes = {
  room: PropTypes.shape({
    id: PropTypes.number.isRequired,
    friendly_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
