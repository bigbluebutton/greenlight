import React from 'react';
import { Badge } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { UsersIcon } from '@heroicons/react/outline';

export default function MeetingParticipantsBadge({ count }) {
  const { t } = useTranslation();

  return (
    <div>
      <Badge className="rounded-pill participants-badge ms-2">
        {/* { t('room.meeting.participant', { count }) } */}
        { count }
        <UsersIcon className="hi-xs" />
      </Badge>
    </div>
  );
}
