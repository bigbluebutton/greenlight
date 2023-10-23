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

import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { ShareIcon, LinkIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';
import { localizeDateTimeString } from '../../helpers/DateTimeHelper';
import Spinner from '../shared_components/utilities/Spinner';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';
import MeetingBadges from './MeetingBadges';
import UserBoardIcon from './UserBoardIcon';
import Modal from '../shared_components/modals/Modal';
import ShareRoomForm from './room/forms/ShareRoomForm';

export default function RoomCard({ room }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(room.friendly_id); }, [room.friendly_id]);
  const startMeeting = useStartMeeting(room.friendly_id);
  const currentUser = useAuth();
  const localizedTime = localizeDateTimeString(room?.last_session, currentUser?.language);

  return (
    <Card id="room-card" className="h-100 card-shadow border-0">
      <Card.Body className="pb-0" onClick={handleClick}>
        <Stack direction="horizontal">
          <div className="room-icon rounded">
            {room?.shared_owner
              ? <LinkIcon className="hi-m text-brand pt-4 d-block mx-auto" />
              : <UserBoardIcon className="hi-m text-brand pt-4 d-block mx-auto" />}
          </div>
          {room?.online
            && <MeetingBadges count={room?.participants} />}
        </Stack>

        <Stack className="my-4">
          <Card.Title className="mb-0"> { room.name } </Card.Title>
          { room.shared_owner && (
            <span className="text-muted">{ t('room.shared_by') } {' '} <strong>{ room.shared_owner }</strong></span>
          )}
          {room.last_session ? (
            <span className="text-muted"> {t('room.last_session', { localizedTime })} </span>
          ) : (
            <span className="text-muted mt-2"> {t('room.no_last_session')} </span>
          )}
        </Stack>
      </Card.Body>
      <Card.Footer className="bg-white">
        <Modal
          size="lg"
          modalButton={(
            <Button
              variant="icon"
            >
              <ShareIcon className="hi-m mt-1 text-muted" />
            </Button>
          )}
          title={t('room.meeting.share_meeting')}
          body={<ShareRoomForm room={room} friendly_id={room.friendly_id} />}
        />

        <Button variant="brand-outline" className="btn btn-md float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
          {startMeeting.isLoading && <Spinner className="me-2" />}
          {room.online ? (
            t('join')
          ) : (
            t('start')
          )}
        </Button>
      </Card.Footer>
    </Card>
  );
}

RoomCard.defaulProps = {
  room: PropTypes.shape({
    last_session: '',
  }),
};

RoomCard.propTypes = {
  room: PropTypes.shape({
    id: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    last_session: PropTypes.string,
    shared_owner: PropTypes.string,
    online: PropTypes.bool,
    participants: PropTypes.number,
    voice_bridge: PropTypes.string,
    voice_bridge_phone_number: PropTypes.string,
  }).isRequired,
};
