import React from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import { Button, Col } from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useRoom from '../../hooks/queries/rooms/useRoom';
import Spinner from '../shared/stylings/Spinner';
import subscribeToRoom from '../../channels/rooms_channel';

export default function RoomJoin() {
  const { friendlyId } = useParams();
  const { isLoading, data: room } = useRoom(friendlyId);
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
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
          <Button onClick={() => subscribeToRoom(friendlyId)}>Join</Button>
        </Card.Footer>
      </Card>
    </div>
  );
}
