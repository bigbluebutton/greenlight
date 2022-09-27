import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import MeetingStatusBadge from './MeetingStatusBadge';
import MeetingParticipantsBadge from './MeetingParticipantsBadge';

export default function MeetingBadges({ active, count }) {
  return (
    <Stack direction="horizontal" gap={0} className="room-card-badges ms-auto mb-auto">
      { active
        && <MeetingStatusBadge />}
      { count >= 1
        && <MeetingParticipantsBadge count={count} />}
    </Stack>
  );
}

MeetingBadges.propTypes = {
  active: PropTypes.bool.isRequired,
  count: PropTypes.number.isRequired,
};
