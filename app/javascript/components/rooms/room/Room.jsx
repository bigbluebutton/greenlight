import React from 'react';
import {
  Stack, Button, Col, Row,
} from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HomeIcon, Square2StackIcon } from '@heroicons/react/24/outline';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import MeetingBadges from '../MeetingBadges';
import SharedBadge from './SharedBadge';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
  toast.success('Copied');
}

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const { isLoading: isLoadingRoom, data: room } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);

  if (isLoadingRoom) return <Spinner />; // Todo: amir - Revisit this.

  return (
    <div className="wide-background-room">
      <Row className="pt-4">
        <Col>
          <Link to="/rooms">
            <HomeIcon className="hi-m text-brand" />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col className="col-xxl-8">
          <Stack className="room-header-wrapper">
            <Stack direction="horizontal" gap={2}>
              <h1>{room.name}</h1>
              <Stack direction="horizontal" className="mb-1">
                { room?.online
                  && <MeetingBadges count={room?.participants} />}
                { room?.shared && <SharedBadge ownerName={room?.owner_name} /> }
              </Stack>
            </Stack>
            { room.last_session ? (
              <span className="text-muted"> { t('room.last_session', { room }) }  </span>
            ) : (
              <span className="text-muted"> { t('room.no_last_session') } </span>
            )}
          </Stack>
        </Col>
        <Col>
          <Button variant="brand" className="mt-1 mx-2 float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
            { room.online ? (
              t('room.meeting.join_meeting')
            ) : (
              t('room.meeting.start_meeting')
            )}
            {startMeeting.isLoading && <Spinner />}
          </Button>
          <Button variant="brand-outline" className="mt-1 mx-2 float-end" onClick={copyInvite}>
            <Square2StackIcon className="hi-s me-1" />
            { t('copy') }
          </Button>
        </Col>
      </Row>
      <FeatureTabs shared={room?.shared} />
    </div>
  );
}
