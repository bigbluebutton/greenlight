import React from 'react';
import { Badge } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function MeetingParticipantsBadge({ participants }) {
  const { t } = useTranslation();

  return (
    <Badge className="rounded-pill participants-badge ms-2 text-black">
      { participants }
    </Badge>
  );
}
