import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import MeetingStatusBadge from './MeetingStatusBadge';
import MeetingParticipantsBadge from './MeetingParticipantsBadge';
import MeetingSharedBadge from './MeetingSharedBadge';

export default function MeetingBadges({ count, shared, online }) {
  return (
    <Stack direction="horizontal" gap={0} className="room-card-badges">
      { shared
        && <MeetingSharedBadge />}
      { online && (count >= 1)
        && <MeetingParticipantsBadge count={count} />}
      { online
        && <MeetingStatusBadge />}
    </Stack>
  );
}

MeetingBadges.propTypes = {
  count: PropTypes.number,
  shared: PropTypes.string,
  online: PropTypes.bool.isRequired,
};

MeetingBadges.defaultProps = {
  count: 0,
  shared: null,
};
