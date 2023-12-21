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
  Stack, Button, Col, Row,
} from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HomeIcon, Square2StackIcon } from '@heroicons/react/24/outline';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import { localizeDayDateTimeString } from '../../../helpers/DateTimeHelper';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import MeetingBadges from '../MeetingBadges';
import SharedBadge from './SharedBadge';
import RoomNamePlaceHolder from './RoomNamePlaceHolder';
import Title from '../../shared_components/utilities/Title';
import useRoomSettings from '../../../hooks/queries/rooms/useRoomSettings';

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const {
    isLoading: isRoomLoading, data: room,
  } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);
  const currentUser = useAuth();
  const localizedTime = localizeDayDateTimeString(room?.last_session, currentUser?.language);
  const roomSettings = useRoomSettings(friendlyId);

  function copyAccessCode(role) {
    if (role === 'viewer') {
      navigator.clipboard.writeText(roomSettings?.data?.glViewerAccessCode);
      toast.success(t('toast.success.room.copied_viewer_code'));
    }
    if (role === 'moderator') {
      navigator.clipboard.writeText(roomSettings?.data?.glModeratorAccessCode);
      toast.success(t('toast.success.room.copied_moderator_code'));
    }
  }

  function copyInvite() {
    navigator.clipboard.writeText(`${window.location}/join`);
    toast.success(t('toast.success.room.copied_meeting_url'));
  }

  return (
    <>
      <Title>{room?.name}</Title>
      <div className="wide-white">
        <Row className="pt-4">
          <Col>
            <Link to="/rooms">
              <HomeIcon className="hi-m text-brand" />
            </Link>
          </Col>
        </Row>
        <Row className="py-5">
          <Col className="col-4">
            {
                isRoomLoading
                  ? (
                    <RoomNamePlaceHolder />
                  ) : (
                    <Stack className="room-header-wrapper">
                      <Stack direction="horizontal" gap={2}>
                        <h1>{room?.name}</h1>
                        <Stack direction="horizontal" className="mb-1">
                          { room?.online
                            && <MeetingBadges count={room?.participants} />}
                          { room?.shared && <SharedBadge ownerName={room?.owner_name} /> }
                        </Stack>
                      </Stack>
                      { room?.last_session ? (
                        <span className="text-muted"> { t('room.last_session', { localizedTime }) }  </span>
                      ) : (
                        <span className="text-muted"> { t('room.no_last_session') } </span>
                      )}
                    </Stack>
                  )
              }
          </Col>
          <Col>
            <Button variant="brand" className="start-meeting-btn mt-1 mx-2 float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
              {startMeeting.isLoading && <Spinner className="me-2" />}
              { room?.online ? (
                t('room.meeting.join_meeting')
              ) : (
                t('room.meeting.start_meeting')
              )}
            </Button>
            <Button variant="brand-outline" className="mt-1 mx-2 float-end" onClick={() => copyInvite()}>
              <Square2StackIcon className="hi-s me-1" />
              { t('copy') }
            </Button>
            { roomSettings?.data?.glViewerAccessCode && (
            <Button variant="brand-outline" className="mt-1 mx-2 float-end" onClick={() => copyAccessCode('viewer')}>
              <Square2StackIcon className="hi-s me-1" />
              { t('copy_viewer_code') }
            </Button>
            )}
            { roomSettings?.data?.glModeratorAccessCode && (
            <Button variant="brand-outline" className="mt-1 mx-2 float-end" onClick={() => copyAccessCode('moderator')}>
              <Square2StackIcon className="hi-s me-1" />
              { t('copy_moderator_code') }
            </Button>
            )}
          </Col>
        </Row>
      </div>

      <FeatureTabs />
    </>
  );
}
