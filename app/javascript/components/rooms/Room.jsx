import React from 'react';
import { Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { House } from 'react-bootstrap-icons';
import ButtonLink from '../stylings/buttons/ButtonLink';
import FeatureTabs from './FeatureTabs';
import Spinner from '../stylings/Spinner';
import useRoom from '../../hooks/queries/rooms/useRoom';

export default function Room() {
  const { friendlyId } = useParams();

  const { isLoading, data: room } = useRoom(friendlyId);
  if (isLoading) return <Spinner />;

  return (
    <>
      <Row>
        <Col>
          <Link to="/rooms">
            <House />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col>
          { room.name }
        </Col>
        <Col>
          <ButtonLink to="/" variant="primary" className="float-end">Start Session</ButtonLink>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  );
}
