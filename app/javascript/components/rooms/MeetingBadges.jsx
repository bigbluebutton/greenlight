import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import MeetingStatusBadge from './MeetingStatusBadge';
import MeetingParticipantsBadge from './MeetingParticipantsBadge';

export default function MeetingBadges({ count }) {
  return (
    <Stack direction="horizontal" gap={0} className="room-card-badges">
      <MeetingStatusBadge />
      { count >= 1
        && <MeetingParticipantsBadge count={count} />}
    </Stack>
  );
}

MeetingBadges.propTypes = {
  count: PropTypes.number,
};

MeetingBadges.defaultProps = {
  count: 0,
};
