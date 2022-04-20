import React, { useState } from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import Spinner from '../shared/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomPlaceHolder from './RoomPlaceHolder';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  const newRoomData = { name: `Room ${Date.now()}` }; // TODO: amir - change this.
  const { handleCreateRoom, isLoading: createRoomIsLoading } = useCreateRoom(newRoomData);
  const [search, setSearch] = useState('');
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <Row className="pt-4 mb-4">
        <Col>
          <input
            id="rooms-search"
            className="rounded border border-dark"
            placeholder=" Search Room"
            type="search"
            style={{ width: '19rem' }}
            onChange={(event) => setSearch(event.target.value)}
          />
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
          rooms.filter((room) => {
            if (search === '') {
              return room;
            }
            if (room.name.toLowerCase().includes(search.toLowerCase())) {
              return room;
            }
            return false;
          }).map((room) => (
            <Col key={room.friendly_id}>
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard id={room.friendly_id} name={room.name} />}
            </Col>
          ))
        }
      </Row>
    </div>
  );
}
