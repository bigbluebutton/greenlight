import React from 'react';
import {
  Row, Col, Button, Form, FormControl,
} from 'react-bootstrap';
import Spinner from '../shared/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomPlaceHolder from './RoomPlaceHolder';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  const newRoomData = { name: `Room ${Date.now()}` }; // TODO: amir - change this.
  const { handleCreateRoom, isLoading: createRoomIsLoading } = useCreateRoom(newRoomData);
  if (isLoading) return <Spinner />; // TODO: amir - revisit this.

  return (
    <>
      <Row className="mt-4 mb-4">
        <Col>
          {/* TODO: May need to change search form when implementing search functionality */}
          <Form className="d-flex">
            <FormControl
              type="search"
              placeholder="Search"
              className=""
              style={{ width: '19rem' }}
              aria-label="Search"
            />
            <Button className="ms-2" variant="outline-secondary">Search</Button>
          </Form>
        </Col>
        <Col>
          {/* TODO: Set this button to create new room page */}
          <Button className="float-end" onClick={handleCreateRoom} disabled={createRoomIsLoading}>
            + New Room {' '}
            {createRoomIsLoading && <Spinner />}
          </Button>
        </Col>
      </Row>
      <Row md={4} className="g-4">
        {
          rooms.map((room) => (
            <Col key={room.friendly_id}>
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard id={room.friendly_id} name={room.name} />}
            </Col>
          ))
        }
      </Row>
    </>
  );
}
