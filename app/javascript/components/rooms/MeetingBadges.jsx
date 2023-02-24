// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
