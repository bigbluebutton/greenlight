import React, { useState } from 'react';
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomCardPlaceHolder from './RoomCardPlaceHolder';
import Modal from '../shared_components/modals/Modal';
import CreateRoomForm from './room/forms/CreateRoomForm';
import { useAuth } from '../../contexts/auth/AuthProvider';
import SearchBar from '../shared_components/search/SearchBar';
import EmptyRoomsList from './EmptyRoomsList';

export default function RoomsList() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState('');
  const { isLoading, data: rooms } = useRooms(searchInput);
  const currentUser = useAuth();
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

  if (rooms?.length === 0) return <EmptyRoomsList />;

  return (
    <>
      <Stack direction="horizontal" className="mt-5" gap={3}>
        <div>
          <SearchBar searchInput={searchInput} id="rooms-search" setSearchInput={setSearchInput} />
        </div>
        <Modal
          modalButton={<Button variant="brand" className="ms-auto me-xxl-1">{ t('room.add_new_room') }</Button>}
          title={t('room.create_new_room')}
          body={<CreateRoomForm mutation={mutationWrapper} userId={currentUser.id} />}
        />
      </Stack>
      <Row className="g-4 mt-4">
        {
          // eslint-disable-next-line react/no-array-index-key
          (isLoading && [...Array(8)].map((val, idx) => <Col key={idx} className="col-md-auto mt-0 mb-4"><RoomCardPlaceHolder /></Col>))
          || rooms?.map((room) => (
            <Col key={room.friendly_id} className="col-md-auto col-xs-12 mt-0 mb-4">
              {(room.optimistic && <RoomCardPlaceHolder />) || <RoomCard room={room} />}
            </Col>
          ))
        }
      </Row>
    </>
  );
}
