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

import React, {
  useEffect, useMemo, useState,
} from 'react';
import {
  Badge, Button, Form, Stack, Table,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import {
  ArrowTopRightOnSquareIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
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
import { getRoomVisual } from '../../helpers/RoomVisuals';

function RoomTableRow({ room, language }) {
  const { t } = useTranslation();
  const startMeeting = useStartMeeting(room.friendly_id);
  const localizedTime = room?.last_session ? localizeDateTimeString(room.last_session, language) : null;
  const roomVisual = getRoomVisual(room);

  return (
    <tr>
      <td>
        <div className="ak-room-list-room-main">
          <span className="ak-room-list-visual" aria-hidden="true">
            {roomVisual.imageUrl ? (
              <img src={roomVisual.imageUrl} alt="" className="ak-room-list-visual-image" />
            ) : roomVisual.emoji}
          </span>
          <div>
            <div className="ak-room-list-room-name">{room.name}</div>
            <div className="ak-room-list-room-id">{room.friendly_id}</div>
          </div>
        </div>
      </td>
      <td>
        <span className={`ak-room-list-status ${room.online ? 'is-live' : 'is-idle'}`}>
          {room.online ? t('online') : 'Idle'}
        </span>
      </td>
      <td>
        {room.shared_owner ? (
          <span className="ak-room-list-muted">{room.shared_owner}</span>
        ) : (
          <span className="ak-room-list-muted">-</span>
        )}
      </td>
      <td>
        <span className="ak-room-list-count">
          <UsersIcon aria-hidden="true" />
          {room.participants || 0}
        </span>
      </td>
      <td>
        {localizedTime ? (
          <span className="ak-room-list-muted">{localizedTime}</span>
        ) : (
          <span className="ak-room-list-muted">{t('room.no_last_session')}</span>
        )}
      </td>
      <td className="text-end">
        <div className="ak-room-list-actions">
          <Button
            as={Link}
            to={`/rooms/${room.friendly_id}`}
            variant="brand-outline"
            className="btn btn-sm ak-room-list-action-btn"
          >
            <ArrowTopRightOnSquareIcon className="hi-s me-1" />
            Detail
          </Button>
          <Button
            variant="brand"
            className="btn btn-sm ak-room-list-action-btn"
            onClick={startMeeting.mutate}
            disabled={startMeeting.isLoading}
          >
            {startMeeting.isLoading && <Spinner className="me-1" />}
            <PlayIcon className="hi-s me-1" />
            {room.online ? 'Join Live Session' : 'Start New Session'}
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
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [page, setPage] = useState(1);
  const { isLoading, data: rooms } = useRooms(searchInput);
  const currentUser = useAuth();
  const currentUserId = currentUser?.id;
  const canCreate = currentUser?.permissions?.CreateRoom;
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUserId, ...args });
  const currentLanguage = currentUser?.language || 'en';
  const totalPages = useMemo(() => Math.max(Math.ceil((rooms?.length || 0) / rowsPerPage), 1), [rooms?.length, rowsPerPage]);
  const pagedRooms = useMemo(() => {
    if (!rooms?.length) return [];
    const startIndex = (page - 1) * rowsPerPage;
    return rooms.slice(startIndex, startIndex + rowsPerPage);
  }, [page, rooms, rowsPerPage]);

  useEffect(() => {
    setPage(1);
  }, [searchInput, rowsPerPage]);

  useEffect(() => {
    if (page > totalPages) {
      setPage(totalPages);
    }
  }, [page, totalPages]);

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
              size="lg"
              id="create-room-modal"
              body={<CreateRoomForm mutation={mutationWrapper} userId={currentUserId} />}
            />
        )}
      </Stack>

      <div className="ak-room-list-wrap mt-4">
        <Table responsive className="ak-room-list-table mb-0">
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
                  <div className="ak-room-list-loading">
                    <Badge bg="light" text="dark">Loading rooms...</Badge>
                  </div>
                </td>
              </tr>
            ))}
            {!isLoading && rooms?.length > 0 && pagedRooms.map((room) => (
              <RoomTableRow key={room.friendly_id} room={room} language={currentLanguage} />
            ))}
          </tbody>
        </Table>
        {!isLoading && !rooms?.length && (
          <div className="p-3">
            <NoSearchResults text={t('room.search_not_found')} searchInput={searchInput} />
          </div>
        )}
        {!isLoading && !!rooms?.length && (
          <div className="ak-room-list-footer">
            <div className="ak-room-list-pagination">
              <span className="ak-room-list-muted">
                Showing {Math.min((page - 1) * rowsPerPage + 1, rooms.length)}-{Math.min(page * rowsPerPage, rooms.length)} of {rooms.length}
              </span>
              <Form.Select
                size="sm"
                className="ak-room-list-page-select"
                value={rowsPerPage}
                onChange={(event) => setRowsPerPage(parseInt(event.target.value, 10))}
              >
                {[5, 10, 20, 50].map((value) => (
                  <option key={value} value={value}>{value} rows</option>
                ))}
              </Form.Select>
            </div>

            <div className="ak-room-list-pagination">
              <Button
                variant="brand-outline"
                className="btn btn-sm ak-room-list-nav-btn"
                onClick={() => setPage((current) => Math.max(current - 1, 1))}
                disabled={page <= 1}
              >
                <ChevronLeftIcon className="hi-s me-1" />
                Prev
              </Button>
              <span className="ak-room-list-page-indicator">Page {page} / {totalPages}</span>
              <Button
                variant="brand-outline"
                className="btn btn-sm ak-room-list-nav-btn"
                onClick={() => setPage((current) => Math.min(current + 1, totalPages))}
                disabled={page >= totalPages}
              >
                Next
                <ChevronRightIcon className="hi-s ms-1" />
              </Button>
            </div>
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
