import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy } from '@fortawesome/free-regular-svg-icons';
import { faChalkboardUser } from '@fortawesome/free-solid-svg-icons';
import Spinner from '../shared/stylings/Spinner';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';

function copyInvite(friendlyId) {
  navigator.clipboard.writeText(`${window.location}/${friendlyId}/join`);
}
export default function RoomCard(props) {
  const { id: friendlyId, name } = props;
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(friendlyId); }, [friendlyId]);
  const { handleStartMeeting, isLoading: startMeetingIsLoading } = useStartMeeting(friendlyId);

  return (
    <Card className="rooms-card shadow-sm" style={{ height: '19rem', overflow: 'hidden' }} border="light">
      <Card.Body style={{ maxHeight: '12rem', overflow: 'auto' }} className="room-card-top pb-0" onClick={handleClick}>
        <FontAwesomeIcon icon={faChalkboardUser} size="3x" className="mb-4" />
        <Card.Title> {name} </Card.Title>
      </Card.Body>
      <Card.Body style={{ maxHeight: '7rem', overflow: 'auto' }} className="pt-0">
        {/* TODO: Hadi- Make last session dynamic per room */}
        <Card.Text className="text-muted"> Last meeting... </Card.Text>
        <hr />
        <FontAwesomeIcon className="room-card-top" icon={faCopy} size="lg" onClick={() => copyInvite(friendlyId)} />
        <Button variant="outline-secondary" className="float-end" onClick={handleStartMeeting} disabled={startMeetingIsLoading}>
          Start {' '}
          {startMeetingIsLoading && <Spinner />}
        </Button>
      </Card.Body>
    </Card>
  );
}

RoomCard.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
};
