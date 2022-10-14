import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import MeetingStatusBadge from './MeetingStatusBadge';
import MeetingParticipantsBadge from './MeetingParticipantsBadge';

export default function MeetingBadges({ online, count }) {
  return (
    <Stack direction="horizontal" gap={0} className="room-card-badges">
      { online && (count >= 1)
        && <MeetingParticipantsBadge count={count} />}
      { online
        && <MeetingStatusBadge />}
    </Stack>
  );
}

MeetingBadges.propTypes = {
  count: PropTypes.number,
  online: PropTypes.bool.isRequired,
};

MeetingBadges.defaultProps = {
  count: 0,
};
