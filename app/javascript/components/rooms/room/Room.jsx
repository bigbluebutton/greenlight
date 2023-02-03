import React from 'react';
import {
  Stack, Button, Col, Row,
} from 'react-bootstrap';
import {
  Link, Navigate, useLocation, useParams,
} from 'react-router-dom';
import { HomeIcon, Square2StackIcon } from '@heroicons/react/24/outline';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import MeetingBadges from '../MeetingBadges';
import SharedBadge from './SharedBadge';
import RoomNamePlaceHolder from './RoomNamePlaceHolder';

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const {
    isLoading, isError, data: room, error,
  } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);
  const location = useLocation();

  function copyInvite() {
    navigator.clipboard.writeText(`${window.location}/join`);
    toast.success(t('toast.success.room.copied_meeting_url'));
  }

  // Custom logic to redirect from Rooms page to join page if this isnt the users room and they're not allowed to view it
  if (isError && error.response.status === 403) {
    return <Navigate to={`${location.pathname}/join`} />;
  }

  return (
    <>
      <div className="wide-white">
        <Row className="pt-4">
          <Col>
            <Link to="/rooms">
              <HomeIcon className="hi-m text-brand" />
            </Link>
          </Col>
        </Row>
        <Row className="py-5">
          <Col className="col-xxl-8">
            {
                isLoading
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
                        <span className="text-muted"> { t('room.last_session', { room }) }  </span>
                      ) : (
                        <span className="text-muted"> { t('room.no_last_session') } </span>
                      )}
                    </Stack>
                  )
              }
          </Col>
          <Col>
            <Button variant="brand" className="mt-1 mx-2 float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
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
          </Col>
        </Row>
      </div>

      <FeatureTabs shared={room?.shared} />
    </>
  );
}
