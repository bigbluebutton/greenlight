import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { UserIcon, DuplicateIcon, LinkIcon } from '@heroicons/react/outline';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import Spinner from '../shared_components/utilities/Spinner';
import useStartMeeting from '../../hooks/mutations/rooms/useStartMeeting';
import MeetingBadges from './MeetingBadges';

function copyInvite(friendlyId) {
  navigator.clipboard.writeText(`${window.location}/${friendlyId}/join`);
  toast.success('Copied');
}

export default function RoomCard({ room }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(room.friendly_id); }, [room.friendly_id]);
  const startMeeting = useStartMeeting(room.friendly_id);

  return (
    <Card id="room-card" className="h-100 shadow-sm border-0">
      <Card.Body className="pb-0" onClick={handleClick}>
        <Stack direction="horizontal">
          <div className="room-icon rounded">
            { room.shared_owner ? (
              <LinkIcon className="hi-m text-brand pt-4 d-block mx-auto" />
            ) : (
              <UserIcon className="hi-m text-brand pt-4 d-block mx-auto" />
            )}
          </div>
          <MeetingBadges active={room.active} count={room.participants} />
        </Stack>

        <Stack className="my-4">
          <Card.Title className="mb-0"> { room.name } </Card.Title>
          { room.shared_owner && (
            <span className="text-muted">{ t('room.shared_by', { room }) } </span>
          )}
          { room.last_session ? (
            <span className="text-muted"> { t('room.last_session', { room }) } </span>
          ) : (
            <span className="text-muted mt-2"> { t('room.no_last_session') } </span>
          )}
        </Stack>
      </Card.Body>
      <Card.Footer className="bg-white">
        <Button
          variant="icon"
          onClick={() => copyInvite(room.friendly_id)}
        >
          <DuplicateIcon className="hi-m text-brand mt-1" />
        </Button>
        <Button variant="brand-outline" className="btn btn-md float-end" onClick={startMeeting.mutate} disabled={startMeeting.isLoading}>
          { room.active ? (
            t('join')
          ) : (
            t('start')
          )}
          {startMeeting.isLoading && <Spinner />}
        </Button>
      </Card.Footer>
    </Card>
  );
}

RoomCard.propTypes = {
  room: PropTypes.shape({
    id: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    last_session: PropTypes.string.isRequired,
    shared_owner: PropTypes.string,
    active: PropTypes.bool,
    participants: PropTypes.number,
  }).isRequired,
};
