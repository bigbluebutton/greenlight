import React from 'react';
import { Badge } from 'react-bootstrap';
import { LinkIcon } from '@heroicons/react/24/outline';

export default function MeetingSharedBadge() {
  return (
    <div>
      <Badge className="rounded-pill participants-badge ms-2">
        <LinkIcon className="hi-xs" />
      </Badge>
    </div>
  );
}
