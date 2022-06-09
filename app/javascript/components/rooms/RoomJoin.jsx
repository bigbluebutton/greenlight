import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import {
  Button, Col, InputGroup, Row,
} from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useRoom from '../../hooks/queries/rooms/useRoom';
import useRoomJoin from '../../hooks/queries/rooms/useRoomJoin';
import Spinner from '../shared/stylings/Spinner';
import useRoomStatus from '../../hooks/queries/rooms/useRoomStatus';
import Avatar from '../users/Avatar';

function waitOrJoin(refetchJoin, refetchStatus, setWaiting) {
  refetchStatus();
  refetchJoin();
  setWaiting(true);
}

export default function RoomJoin() {
  const { friendlyId } = useParams();
  const [name, setName] = useState('');
  const [waiting, setWaiting] = useState(false);
  const { isLoading, data: room } = useRoom(friendlyId, true);
  const { refetch: refetchJoin } = useRoomJoin(friendlyId, name);
  const { refetch: refetchStatus } = useRoomStatus(friendlyId, name);
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-6 mx-auto p-4 border-0 shadow-sm">
          <Row>
            <Col className="col-8 mt-4">
              <Card.Subtitle className="text-muted mb-1">You have been invited to join</Card.Subtitle>
              <h2 className="pt-1">
                { room.name }
              </h2>
            </Col>
            <Col className="ms-auto col-4">
              <Avatar className="float-end" avatar={room.owner.avatar} radius={100} />
              <p className="float-end">{room.owner.name}</p>
            </Col>
          </Row>

          <Card.Footer className="mt-2 bg-white">
            { waiting ? (
              <div className="mt-3">
                <Row>
                  <Col className="col-10">
                    <p className="mb-1">The meeting hasn&apos;t started yet</p>
                    <p className="mb-0 text-muted">You will automatically join when the meeting starts</p>
                  </Col>
                  <Col className="col-2">
                    <Spinner className="float-end" />
                  </Col>
                </Row>
              </div>
            ) : (
              <div className="text-center">
                <InputGroup className="mt-3">
                  <input
                    type="text"
                    id="join-name"
                    placeholder="Enter your name..."
                    className="form-control"
                    onChange={(event) => setName(event.target.value)}
                  />
                  <Button className="px-4" onClick={() => waitOrJoin(refetchJoin, refetchStatus, setWaiting)}>Join</Button>
                </InputGroup>
              </div>
            )}
          </Card.Footer>
        </Card>
      </div>
    </div>
  );
}
