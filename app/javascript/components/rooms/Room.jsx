import React from 'react';
import { Button, Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faHouseChimney } from '@fortawesome/free-solid-svg-icons';
import { faCopy } from '@fortawesome/free-regular-svg-icons';
import ButtonLink from '../shared/stylings/buttons/ButtonLink';
import FeatureTabs from './FeatureTabs';
import Spinner from '../shared/stylings/Spinner';
import useRoom from '../../hooks/queries/rooms/useRoom';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
}

export default function Room() {
  const { friendlyId } = useParams();

  const { isLoading, data: room } = useRoom(friendlyId);
  if (isLoading) return <Spinner />;

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
          <h2>{ room.name }</h2>
          <p className="text-muted">Last Session: Jan 17,2022 11:30am</p>
        </Col>
        <Col>
          <ButtonLink to="/" variant="primary" className="mt-1 mx-2 float-end">
            Start Session
          </ButtonLink>
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
