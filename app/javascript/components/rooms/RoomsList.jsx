import React, { useState } from 'react';
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
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
  const [search, setSearch] = useState('');
  const { isLoading, data: rooms } = useRooms(search);
  const currentUser = useAuth();
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

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
          // eslint-disable-next-line react/no-array-index-key
          (isLoading && [...Array(8)].map((val, idx) => <Col key={idx} className="mt-0 mb-4"><RoomPlaceHolder /></Col>))
          || rooms.map((room) => (
            <Col key={room.friendly_id} className="mt-0 mb-4">
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard room={room} />}
            </Col>
          ))
        }
      </Row>
    </>
  );
}
