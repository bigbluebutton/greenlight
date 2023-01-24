import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import useUpdateRecording from '../../../hooks/mutations/recordings/useUpdateRecording';

export default function UpdateRecordingForm({
  name, recordId, hidden, setIsUpdating, setIsEditing,
}) {
  const updateRecording = useUpdateRecording(recordId);

  useEffect(() => { setIsUpdating(updateRecording.isLoading); }, [updateRecording.isLoading]);

  return (
    <input
      type="text"
      className="form-control"
      hidden={hidden}
      disabled={updateRecording.isLoading}
      onBlur={(e) => { setIsEditing(false); updateRecording.mutate({ recording: { name: e.target.value } }); }}
      defaultValue={name}
    />
  );
}

UpdateRecordingForm.defaultProps = {
  name: '',
  hidden: false,
  setIsUpdating: () => { },
  setIsEditing: () => { },
};

UpdateRecordingForm.propTypes = {
  name: PropTypes.string,
  recordId: PropTypes.string.isRequired,
  hidden: PropTypes.bool,
  setIsUpdating: PropTypes.func,
  setIsEditing: PropTypes.func,
};
