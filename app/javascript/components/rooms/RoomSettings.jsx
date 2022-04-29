import React from 'react';
import { Row, Button, Col } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Spinner from '../shared/stylings/Spinner';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';

export default function RoomSettings() {
  const { friendlyId } = useParams();
  const { handleDeleteRoom, isLoading: deleteRoomIsLoading } = useDeleteRoom(friendlyId);

  return (
    <Row className="wide-background">
      <Col />
      <Col>
        {/* TODO: Hadi- This is temporary (waiting to see where the delete button should be for room) */}
        <Button id="delete-room" className="mt-1 mx-2 float-end" onClick={handleDeleteRoom}>
          Delete Room
          {deleteRoomIsLoading && <Spinner />}
        </Button>
      </Col>
    </Row>
  );
}
