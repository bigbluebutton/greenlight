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
