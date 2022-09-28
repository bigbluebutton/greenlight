import React, { useState } from 'react';
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Spinner from '../shared_components/utilities/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomPlaceHolder from './RoomPlaceHolder';
import Modal from '../shared_components/modals/Modal';
import CreateRoomForm from './room/forms/CreateRoomForm';
import SearchBar from '../shared_components/search/SearchBar';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function RoomsList() {
  const { t } = useTranslation();
  const { isLoading, data: rooms } = useRooms();
  const [search, setSearch] = useState('');
  const currentUser = useAuth();
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

  if (isLoading) return <Spinner />;

  return (
    <>
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBar id="rooms-search" setSearch={setSearch} />
        </div>
        <Modal
          modalButton={<Button variant="brand" className="ms-auto">{ t('room.add_new_room') }</Button>}
          title="Create New Room"
          body={<CreateRoomForm mutation={mutationWrapper} userId={currentUser.id} />}
        />
      </Stack>
      <Row md={4} className="g-4 pb-4 mt-4">
        {
          rooms.sort((a, b) => b.active - a.active).filter((room) => {
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
    </>
  );
}
