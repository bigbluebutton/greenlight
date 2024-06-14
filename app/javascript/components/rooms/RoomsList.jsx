// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
import NoSearchResults from '../shared_components/search/NoSearchResults';

export default function RoomsList() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState('');
  const { isLoading, data: rooms } = useRooms(searchInput);
  const currentUser = useAuth();
  const canCreate = currentUser?.permissions.CreateRoom;
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

  if (!isLoading && rooms?.length === 0 && !searchInput) {
    return <EmptyRoomsList />;
  }

  return (
    <>
      <Stack direction="horizontal" className="pt-5" gap={3}>
        <div>
          <SearchBar searchInput={searchInput} id="rooms-search" setSearchInput={setSearchInput} />
        </div>
        { (canCreate === 'true') && (
          <Modal
            modalButton={(
              <Button
                variant="brand"
                className="ms-auto me-xxl-1"
              >{t('room.add_new_room')}
              </Button>
            )}
            title={t('room.create_new_room')}
            body={<CreateRoomForm mutation={mutationWrapper} userId={currentUser.id} />}
          />
        )}
      </Stack>
      <Row className="g-4 mt-4">
        {
          (isLoading && [...Array(8)].map((val, idx) => (
            <Col
              // eslint-disable-next-line react/no-array-index-key
              key={idx}
              className="col-md-auto mt-0 mb-4"
            ><RoomCardPlaceHolder />
            </Col>
          )))
          || (rooms?.length && rooms?.map((room) => (
            <Col key={room.friendly_id} className="col-md-auto col-xs-12 mt-0 mb-4">
              {(room.optimistic && <RoomCardPlaceHolder />) || <RoomCard room={room} />}
            </Col>
          )))
          || <NoSearchResults text={t('room.search_not_found')} searchInput={searchInput} />
        }
      </Row>
    </>
  );
}
