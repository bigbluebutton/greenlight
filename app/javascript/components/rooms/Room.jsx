import React from 'react';
import { Button, Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HouseDoor, Link45deg } from 'react-bootstrap-icons';
import ButtonLink from '../stylings/buttons/ButtonLink';
import FeatureTabs from './FeatureTabs';
import Spinner from '../stylings/Spinner';
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
            <HouseDoor size={24} />
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
            <Link45deg />
            Copy
          </Button>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  );
}
