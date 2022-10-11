import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import MeetingStatusBadge from './MeetingStatusBadge';
import MeetingParticipantsBadge from './MeetingParticipantsBadge';
import MeetingSharedBadge from './MeetingSharedBadge';

export default function MeetingBadges({ count, shared, online }) {
  return (
    <Stack direction="horizontal" gap={0} className="room-card-badges">
      { online
        && (
          <>
            <MeetingStatusBadge />
            <MeetingParticipantsBadge count={count} />
          </>
        )}
      { shared
        && <MeetingSharedBadge />}
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
