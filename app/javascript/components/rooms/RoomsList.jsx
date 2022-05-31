import React, { useState } from 'react';
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import Spinner from '../shared/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import RoomPlaceHolder from './RoomPlaceHolder';
import CreateRoomModal from '../shared/Modal';
import CreateRoomForm from '../forms/CreateRoomForm';
import SearchBar from '../shared/SearchBar';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  const [search, setSearch] = useState('');
  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <SearchBar id="rooms-search" setSearch={setSearch} />
        <CreateRoomModal
          modalButton={<Button variant="primary" className="ms-auto">+ New Room</Button>}
          title="Create New Room"
          body={<CreateRoomForm />}
        />
      </Stack>
      <Row md={4} className="g-4 pb-4 mt-4">
        {
          rooms.filter((room) => {
            if (room.name.toLowerCase().includes(search.toLowerCase())) {
              return room;
            }
            return false;
          }).map((room) => (
            <Col key={room.friendly_id} className="mt-0">
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard id={room.friendly_id} name={room.name} />}
            </Col>
          ))
        }
      </Row>
    </div>
  );
}
