import React from 'react';
import PropTypes from 'prop-types';
import useUpdateRecordingVisibility from '../../../hooks/mutations/recordings/useUpdateRecordingVisibility';
import useUpdateRecording from '../../../hooks/mutations/recordings/useUpdateRecording';
import useDeleteRecording from '../../../hooks/mutations/recordings/useDeleteRecording';
import RecordingRow from '../RecordingRow';

export default function RoomsRecordingRow({ recording }) {
  return (
    <RecordingRow
      recording={recording}
      visibilityMutation={useUpdateRecordingVisibility}
      updateMutation={useUpdateRecording}
      deleteMutation={useDeleteRecording}
    />
  );
}

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
};
