import React from 'react';
import { Button, Col, Row } from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { HomeIcon, DuplicateIcon } from '@heroicons/react/outline';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';

function copyInvite() {
  navigator.clipboard.writeText(`${window.location}/join`);
  toast.success('Copied');
}

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const { isLoading, data: room } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);

  if (isLoading) return <Spinner />; // Todo: amir - Revisit this.
  return (
    <div className="wide-background-room">
      <Row className="pt-4">
        <Col>
          <Link to="/rooms">
            <HomeIcon className="hi-l text-brand" />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col>
          <h3>{room.name}</h3>
          <p className="text-muted"> { room.created_at }</p>
        </Col>
        <Col>
          <Button variant="brand" className="mt-1 mx-2 float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
            { t('room.meeting.start_meeting') }
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
