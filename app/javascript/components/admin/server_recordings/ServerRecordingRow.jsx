import React from 'react';
import PropTypes from 'prop-types';
import RecordingRow from '../../recordings/RecordingRow';
import useUpdateRecordingVisibility from '../../../hooks/mutations/recordings/useUpdateRecordingVisibility';
import useUpdateRecording from '../../../hooks/mutations/recordings/useUpdateRecording';
import useDeleteRecording from '../../../hooks/mutations/recordings/useDeleteRecording';

export default function ServerRecordingRow({ recording }) {
  // TODO: Change all mutations when their APIs becomes ready.
  return (
    <RecordingRow
      recording={recording}
      visibilityMutation={useUpdateRecordingVisibility}
      updateMutation={useUpdateRecording}
      deleteMutation={useDeleteRecording}
    />
  );
}

ServerRecordingRow.propTypes = {
  recording: PropTypes.shape({
    id: PropTypes.number.isRequired,
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
