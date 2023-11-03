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
import PropTypes from 'prop-types';
import useUpdateRecordingVisibility from '../../../hooks/mutations/recordings/useUpdateRecordingVisibility';
import useDeleteRecording from '../../../hooks/mutations/recordings/useDeleteRecording';
import RecordingRow from '../RecordingRow';

export default function RoomsRecordingRow({ recording, adminTable, dropUp }) {
  return (
    <RecordingRow
      adminTable={adminTable}
      recording={recording}
      visibilityMutation={useUpdateRecordingVisibility}
      deleteMutation={useDeleteRecording}
      dropUp={dropUp}
    />
  );
}

RoomsRecordingRow.defaultProps = {
  adminTable: false,
  dropUp: false,
};

RoomsRecordingRow.propTypes = {
  recording: PropTypes.shape({
    id: PropTypes.string.isRequired,
    record_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    participants: PropTypes.number.isRequired,
    formats: PropTypes.arrayOf(PropTypes.shape({
      url: PropTypes.string.isRequired,
      recording_type: PropTypes.string.isRequired,
    })),
    visibility: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  }).isRequired,
  adminTable: PropTypes.bool,
  dropUp: PropTypes.bool,
};
