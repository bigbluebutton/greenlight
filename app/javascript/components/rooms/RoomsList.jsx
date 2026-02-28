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
  Badge, Button, Stack, Table,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import {
  ArrowTopRightOnSquareIcon,
  PlayIcon,
  UsersIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';
import Modal from '../shared_components/modals/Modal';
import CreateRoomForm from './room/forms/CreateRoomForm';
import { useAuth } from '../../contexts/auth/AuthProvider';
import SearchBar from '../shared_components/search/SearchBar';
import EmptyRoomsList from './EmptyRoomsList';
import NoSearchResults from '../shared_components/search/NoSearchResults';
import Spinner from '../shared_components/utilities/Spinner';
import { localizeDateTimeString } from '../../helpers/DateTimeHelper';

function RoomTableRow({ room, language }) {
  const { t } = useTranslation();
  const startMeeting = useStartMeeting(room.friendly_id);
  const localizedTime = room?.last_session ? localizeDateTimeString(room.last_session, language) : null;

  return (
    <tr>
      <td className="ak-room-table-room-cell">
        <div className="ak-room-table-room-name">{room.name}</div>
        <div className="ak-room-table-room-id">{room.friendly_id}</div>
      </td>
      <td>
        <span className={`ak-room-table-status ${room.online ? 'is-live' : 'is-idle'}`}>
          {room.online ? t('online') : 'Idle'}
        </span>
      </td>
      <td>
        {room.shared_owner ? (
          <span className="ak-room-table-muted">{room.shared_owner}</span>
        ) : (
          <span className="ak-room-table-muted">-</span>
        )}
      </td>
      <td>
        <span className="ak-room-table-count">
          <UsersIcon aria-hidden="true" />
          {room.participants || 0}
        </span>
      </td>
      <td>
        {localizedTime ? (
          <span className="ak-room-table-muted">{localizedTime}</span>
        ) : (
          <span className="ak-room-table-muted">{t('room.no_last_session')}</span>
        )}
      </td>
      <td className="ak-room-table-actions-cell">
        <div className="ak-room-table-actions">
          <Button
            as={Link}
            to={`/rooms/${room.friendly_id}`}
            variant="brand-outline"
            className="btn btn-sm"
          >
            <ArrowTopRightOnSquareIcon className="hi-s me-2" />
            View
          </Button>
          <Button
            variant="brand"
            className="btn btn-sm"
            onClick={startMeeting.mutate}
            disabled={startMeeting.isLoading}
          >
            {startMeeting.isLoading && <Spinner className="me-2" />}
            <PlayIcon className="hi-s me-2" />
            {room.online ? t('join') : t('start')}
          </Button>
        </div>
      </td>
    </tr>
  );
}

RoomTableRow.propTypes = {
  language: PropTypes.string.isRequired,
  room: PropTypes.shape({
    friendly_id: PropTypes.string.isRequired,
    last_session: PropTypes.string,
    name: PropTypes.string.isRequired,
    online: PropTypes.bool,
    participants: PropTypes.number,
    shared_owner: PropTypes.string,
  }).isRequired,
};

export default function RoomsList({ topSpacingClass = 'pt-5' }) {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState('');
  const { isLoading, data: rooms } = useRooms(searchInput);
  const currentUser = useAuth();
  const canCreate = currentUser?.permissions.CreateRoom;
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });
  const currentLanguage = currentUser?.language || 'en';

  if (!isLoading && rooms?.length === 0 && !searchInput) {
    return <EmptyRoomsList />;
  }

  return (
    <>
      <Stack direction="horizontal" className={`${topSpacingClass} flex-wrap align-items-center`} gap={3}>
        <div className="ak-room-toolbar-search">
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

      <div className="ak-room-table-wrap mt-4">
        <Table responsive className="ak-room-table mb-0">
          <thead>
            <tr>
              <th>Room</th>
              <th>Status</th>
              <th>Shared By</th>
              <th>Users</th>
              <th>Last Session</th>
              <th className="text-end">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading && [...Array(4)].map((_, idx) => (
              <tr key={`loading-row-${idx}`}>
                <td colSpan={6}>
                  <div className="ak-room-table-loading">
                    <Badge bg="light" text="dark">Loading rooms...</Badge>
                  </div>
                </td>
              </tr>
            ))}
            {!isLoading && rooms?.length > 0 && rooms.map((room) => (
              <RoomTableRow key={room.friendly_id} room={room} language={currentLanguage} />
            ))}
          </tbody>
        </Table>
        {!isLoading && !rooms?.length && (
          <div className="p-3">
            <NoSearchResults text={t('room.search_not_found')} searchInput={searchInput} />
          </div>
        )}
      </div>
    </>
  );
}

RoomsList.propTypes = {
  topSpacingClass: PropTypes.string,
};

RoomsList.defaultProps = {
  topSpacingClass: 'pt-5',
};
