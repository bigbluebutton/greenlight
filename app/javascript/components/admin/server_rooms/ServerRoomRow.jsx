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

import React from 'react';
import {
  EyeIcon, EllipsisVerticalIcon, TrashIcon, ArrowTopRightOnSquareIcon, ArrowPathIcon,
} from '@heroicons/react/24/outline';
import { Dropdown, Stack } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import useDeleteServerRoom from '../../../hooks/mutations/admin/server_rooms/useDeleteServerRoom';
import Modal from '../../shared_components/modals/Modal';
import DeleteRoomForm from '../../rooms/room/forms/DeleteRoomForm';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import useRoomStatus from '../../../hooks/mutations/rooms/useRoomStatus';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useRecordingsReSync from '../../../hooks/mutations/admin/server_recordings/useRecordingsReSync';
import { localizeDateTimeString } from '../../../helpers/DateTimeHelper';

export default function ServerRoomRow({ room }) {
  const {
    friendly_id: friendlyId, name, owner, last_session: lastSession, online, participants,
  } = room;
  const { t } = useTranslation();
  const mutationWrapper = (args) => useDeleteServerRoom({ friendlyId, ...args });
  const startMeeting = useStartMeeting(friendlyId);
  const currentUser = useAuth();
  const roomStatusAPI = useRoomStatus(friendlyId);
  const recordingsResyncAPI = useRecordingsReSync(friendlyId);
  const localizedTime = localizeDateTimeString(room?.last_session, currentUser?.language);

  // TODO - samuel: useRoomStatus will not work if room has an access code. Will need to add bypass in MeetingController
  const handleJoin = () => roomStatusAPI.mutate({ name: currentUser.name });

  const renderLastSession = () => {
    if (lastSession == null) {
      return t('admin.server_rooms.no_meeting_yet');
    }
    if (online) {
      return t('admin.server_rooms.current_session', { lastSession: localizedTime });
    }
    return t('admin.server_rooms.last_session', { localizedTime });
  };

  const meetingRunning = () => {
    if (online) {
      return <td className="border-0 text-success"><span class="badge bg-success"> { t('admin.server_rooms.running') } </span></td>;
    }
    return <td className="border-0"><span class="badge bg-danger"> { t('admin.server_rooms.not_running') } </span></td>;
  };

  return (
    <tr className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> {name} </span>
          <span> {renderLastSession()} </span>
        </Stack>
      </td>
      <td className="border-0"> {owner}</td>
      <td className="border-0"> {friendlyId} </td>
      <td className="border-0"> {participants || '-'} </td>
      { meetingRunning() }
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
          <Dropdown.Menu>
            { room.online
              ? (
                <Dropdown.Item onClick={handleJoin}>
                  <ArrowTopRightOnSquareIcon className="hi-s me-2" />
                  {t('join')}
                </Dropdown.Item>
              )
              : (
                <Dropdown.Item onClick={startMeeting.mutate}>
                  <ArrowTopRightOnSquareIcon className="hi-s me-2" />
                  {t('start')}
                </Dropdown.Item>
              )}
            <Dropdown.Item as={Link} to={`/rooms/${friendlyId}`}>
              <EyeIcon className="hi-s me-2" />
              {t('view')}
            </Dropdown.Item>
            <Dropdown.Item onClick={recordingsResyncAPI.mutate}>
              <ArrowPathIcon className="hi-s me-2" />
              {t('admin.server_rooms.resync_recordings')}
            </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><TrashIcon className="hi-s me-2" />{ t('delete') }</Dropdown.Item>}
              body={<DeleteRoomForm mutation={mutationWrapper} />}
            />
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  );
}

ServerRoomRow.propTypes = {
  room: PropTypes.shape({
    name: PropTypes.string.isRequired,
    owner: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    online: PropTypes.bool.isRequired,
    last_session: PropTypes.string,
    participants: PropTypes.number,
  }).isRequired,
};
