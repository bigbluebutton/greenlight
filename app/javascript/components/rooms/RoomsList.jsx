import React, { useState } from 'react';
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import Spinner from '../shared_components/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomPlaceHolder from './RoomPlaceHolder';
import Modal from '../shared_components/Modal';
import CreateRoomForm from '../forms/CreateRoomForm';
import SearchBar from '../shared_components/SearchBar';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  const [search, setSearch] = useState('');

  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBar id="rooms-search" setSearch={setSearch} />
        </div>
        <Modal
          modalButton={<Button variant="brand" className="ms-auto">+ New Room </Button>}
          title="Create New Room"
          body={<CreateRoomForm mutation={useCreateRoom} />}
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
            <Col key={room.friendly_id} className="mt-0 mb-4">
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard room={room} />}
            </Col>
          ))
        }
      </Row>
    </div>
  );
}
