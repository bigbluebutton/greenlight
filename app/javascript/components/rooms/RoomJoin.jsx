import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import { Button, Col, InputGroup } from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useRoom from '../../hooks/queries/rooms/useRoom';
import useRoomJoin from '../../hooks/queries/rooms/useRoomJoin';
import Spinner from '../shared/stylings/Spinner';
import useRoomStatus from '../../hooks/queries/rooms/useRoomStatus';

function waitOrJoin(refetchJoin, refetchStatus) {
  refetchStatus();
  refetchJoin();
}

export default function RoomJoin() {
  const { friendlyId } = useParams();
  const [name, setName] = useState('');
  const { isLoading, data: room } = useRoom(friendlyId);
  const { refetch: refetchJoin } = useRoomJoin(friendlyId, name);
  const { refetch: refetchStatus } = useRoomStatus(friendlyId, name);
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-6 mx-auto p-4 border-0 shadow-sm">
          <div className="mt-4">
            <Col>
              <Card.Subtitle className="text-muted mb-1">You have been invited to join</Card.Subtitle>
              <Card.Title className="pb-2">
                { room.name }
              </Card.Title>
            </Col>
            <Col />
          </div>

          <Card.Footer className="mt-4 bg-white text-center">
            <InputGroup className="mt-3">
              <input
                type="text"
                id="join-name"
                placeholder="Enter your name..."
                className="form-control"
                onChange={(event) => setName(event.target.value)}
              />
              <Button className="px-4" onClick={() => waitOrJoin(refetchJoin, refetchStatus)}>Join</Button>
            </InputGroup>

          </Card.Footer>
        </Card>
      </div>
    </div>
  );
}
