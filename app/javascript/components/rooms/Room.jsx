import React from 'react';
import { Button, Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HomeIcon, DuplicateIcon } from '@heroicons/react/outline';
import FeatureTabs from './FeatureTabs';
import Spinner from '../shared/stylings/Spinner';
import useRoom from '../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
}

export default function Room() {
  const { friendlyId } = useParams();
  const { isLoading, data: room } = useRoom(friendlyId);
  const { handleStartMeeting, isLoading: startMeetingIsLoading } = useStartMeeting(friendlyId);

  if (isLoading) return <Spinner />; // Todo: amir - Revisit this.
  return (
    <>
      <Row className="pt-4">
        <Col>
          <Link to="/rooms">
            <HomeIcon className="w-36 text-primary" />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col>
          <h2>{room.name}</h2>
          <p className="text-muted"> { room.created_at }</p>
        </Col>
        <Col>
          <Button variant="primary" className="mt-1 mx-2 float-end" onClick={handleStartMeeting} disabled={startMeetingIsLoading}>
            Start Meeting {' '}
            {startMeetingIsLoading && <Spinner />}
          </Button>
          <Button variant="primary-light" className="mt-1 mx-2 float-end" onClick={copyInvite}>
            <DuplicateIcon className="w-18" />
            Copy
          </Button>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  );
}
