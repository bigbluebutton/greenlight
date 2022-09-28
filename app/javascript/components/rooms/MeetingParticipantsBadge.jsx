import React from 'react';
import { Badge } from 'react-bootstrap';
import { UsersIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';

export default function MeetingParticipantsBadge({ count }) {
  return (
    <div>
      <Badge className="rounded-pill participants-badge ms-2">
        { count }
        <UsersIcon className="hi-xs" />
      </Badge>
    </div>
  );
}

MeetingParticipantsBadge.propTypes = {
  count: PropTypes.number.isRequired,
};
