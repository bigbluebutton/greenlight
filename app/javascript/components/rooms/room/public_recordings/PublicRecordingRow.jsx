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
import {
  VideoCameraIcon, ClipboardDocumentIcon,
} from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';
import {
  Button, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import { localizeDateTimeString } from '../../../../helpers/DateTimeHelper';
import useRedirectRecordingUrl from '../../../../hooks/mutations/recordings/useRedirectRecordingUrl';
import useCopyRecordingUrl from '../../../../hooks/mutations/recordings/useCopyRecordingUrl';

// TODO: Amir - Refactor this.
export default function PublicRecordingRow({
  recording,
}) {
  const { t } = useTranslation();

  const currentUser = useAuth();
  const redirectRecordingUrl = useRedirectRecordingUrl();
  const copyRecordingUrl = useCopyRecordingUrl();

  const localizedTime = localizeDateTimeString(recording?.recorded_at, currentUser?.language);
  const formats = recording.formats.sort(
    (a, b) => (a.recording_type.toLowerCase() > b.recording_type.toLowerCase() ? 1 : -1),
  );

  return (
    <tr key={recording.id} className="align-middle text-muted border border-2">
      <td className="border-end-0 text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex justify-content-center">
            <VideoCameraIcon className="hi-s text-brand" />
          </div>
          <Stack>
            <strong> {recording.name} </strong>
            <span className="small text-muted"> {localizedTime} </span>
          </Stack>
        </Stack>
      </td>
      <td className="border-0"> {t('recording.length_in_minutes', { recording })} </td>
      <td className="border-0">
        {formats.map((format) => (
          <Button
            onClick={() => redirectRecordingUrl.mutate({ record_id: recording.record_id, format: format.recording_type })}
            className={`btn-sm rounded-pill me-1 mt-1 border-0 btn-format-${format.recording_type.toLowerCase()}`}
            key={`${format.recording_type}-${recording.record_id}`}
          >
            {format.recording_type}
          </Button>
        ))}
      </td>
      <td className="border-start-0">
        <Stack direction="horizontal" className="float-end recordings-icons">
          <Button
            variant="icon"
            className="mt-1 me-3"
            onClick={() => copyRecordingUrl.mutate({ record_id: recording.record_id })}
          >
            <ClipboardDocumentIcon className="hi-s text-muted" />
          </Button>
        </Stack>
      </td>
    </tr>
  );
}

PublicRecordingRow.propTypes = {
  recording: PropTypes.shape({
    id: PropTypes.string.isRequired,
    record_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    formats: PropTypes.arrayOf(PropTypes.shape({
      url: PropTypes.string.isRequired,
      recording_type: PropTypes.string.isRequired,
    })),
    recorded_at: PropTypes.string.isRequired,
  }).isRequired,
};
