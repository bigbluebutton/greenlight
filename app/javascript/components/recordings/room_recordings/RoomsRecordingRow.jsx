import React from 'react';
import PropTypes from 'prop-types';
import useUpdateRecordingVisibility from '../../../hooks/mutations/recordings/useUpdateRecordingVisibility';
import useDeleteRecording from '../../../hooks/mutations/recordings/useDeleteRecording';
import RecordingRow from '../RecordingRow';

export default function RoomsRecordingRow({ recording, adminTable }) {
  return (
    <RecordingRow
      adminTable={adminTable}
      recording={recording}
      visibilityMutation={useUpdateRecordingVisibility}
      deleteMutation={useDeleteRecording}
    />
  );
}

RoomsRecordingRow.defaultProps = {
  adminTable: false,
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
};
