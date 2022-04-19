import React from 'react';
import { Button, Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faHouseChimney } from '@fortawesome/free-solid-svg-icons';
import { faCopy } from '@fortawesome/free-regular-svg-icons';
import FeatureTabs from './FeatureTabs';
import Spinner from '../shared/stylings/Spinner';
import useRoom from '../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
}

export default function Room() {
  const { friendlyId } = useParams();
  const { isLoading, data: room } = useRoom(friendlyId);
  const { handleStartMeeting, isLoading: startMeetingIsLoading } = useStartMeeting(friendlyId);

  const { handleDeleteRoom, isLoading: deleteRoomIsLoading } = useDeleteRoom(friendlyId);

  if (isLoading) return <Spinner />; // Todo: amir - Revisit this.
  return (
    <>
      <Row className="mt-4">
        <Col>
          <Link to="/rooms">
            <FontAwesomeIcon icon={faHouseChimney} size="lg" />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col>
          <h2>{room.name}</h2>
          <p className="text-muted">Last Session: Jan 17,2022 11:30am</p>
        </Col>
        <Col>
          <Button variant="primary" className="mt-1 mx-2 float-end" onClick={handleStartMeeting} disabled={startMeetingIsLoading}>
            Start Meeting {' '}
            {startMeetingIsLoading && <Spinner />}
          </Button>
          {/* TODO: Hadi- This is temporary (waiting to see where the delete button should be for room) */}
          <Button className="mt-1 mx-2 float-end" onClick={handleDeleteRoom}>
            Delete Room
            {deleteRoomIsLoading && <Spinner />}
          </Button>
          <Button variant="light" className="mt-1 mx-2 float-end" onClick={copyInvite}>
            <FontAwesomeIcon icon={faCopy} />
            Copy
          </Button>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  );
}
