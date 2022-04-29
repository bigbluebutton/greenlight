import React, { useState } from 'react';
import {
  Row, Col, Form, FormControl, Button,
} from 'react-bootstrap';
import Spinner from '../shared/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import RoomPlaceHolder from './RoomPlaceHolder';
import CreateRoomModal from '../shared/CreateRoomModal';
import CreateRoomForm from '../forms/CreateRoomForm';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  const [search, setSearch] = useState('');
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background full-height-rooms">
      <Row className="pt-4 mb-3">
        <Col>
          <Form>
            <FormControl
              id="rooms-search"
              className="rounded border"
              placeholder=" Search Room"
              type="search"
              style={{ width: '19rem' }}
              onKeyPress={(e) => (
                e.key === 'Enter' && e.preventDefault()
              )}
              onChange={(event) => setSearch(event.target.value)}
            />
          </Form>
        </Col>
        <Col>
          {/* TODO: Set this button to create new room page */}
          <CreateRoomModal
            modalButton={<Button className="float-end">+ New Room</Button>}
            title="Create New Room"
            body={<CreateRoomForm />}
          />
        </Col>
      </Row>
      <Row md={4} className="g-4 pb-4">
        {
          rooms.filter((room) => {
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
