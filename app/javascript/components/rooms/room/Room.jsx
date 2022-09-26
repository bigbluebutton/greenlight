import React from 'react';
import {
  Stack, Badge, Button, Col, Row,
} from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HomeIcon, DuplicateIcon } from '@heroicons/react/outline';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import useMeetingRunning from '../../../hooks/queries/rooms/useMeetingRunning';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
  toast.success('Copied');
}

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const { isLoading, data: room } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);
  const { isLoadingRunning, data: isRunning } = useMeetingRunning(friendlyId);

  if (isLoadingRunning) return <Spinner />; // Todo: amir - Revisit this.
  if (isLoading) return <Spinner />; // Todo: amir - Revisit this.
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
          <Stack direction="horizontal" gap={2}>
            <h1>{room.name}</h1>
            { isRunning
              && (
                <Badge className="rounded-pill online-pill ms-2 text-success">
                  <span className="blinking-green-dot" /> {t('online')}
                </Badge>
              )}
          </Stack>
          <p className="text-muted"> { room.created_at }</p>
        </Col>
        <Col>
          <Button variant="brand" className="mt-1 mx-2 float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
            { isRunning ? (
              t('room.meeting.join_meeting')
            ) : (
              t('room.meeting.start_meeting')
            )}
            {startMeeting.isLoading && <Spinner />}
          </Button>
          <Button variant="brand-outline" className="mt-1 mx-2 float-end" onClick={copyInvite}>
            <DuplicateIcon className="hi-xs" />
            { t('copy') }
          </Button>
        </Col>
      </Row>
      <FeatureTabs />
    </div>
  );
}
