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

/* eslint-disable react/jsx-props-no-spreading */

import React, { forwardRef } from 'react';
import { useTranslation } from 'react-i18next';
import Popover from 'react-bootstrap/Popover';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import useCopyRecordingUrl from '../../hooks/mutations/recordings/useCopyRecordingUrl';

const CopyRecordingPopover = forwardRef(({
  recording, formats, onCopied, ...popoverProps
}, ref) => {
  const { t } = useTranslation();
  const copyRecordingUrl = useCopyRecordingUrl();

  return (
    <Popover id="popover-basic" ref={ref} {...popoverProps}>
      <Popover.Header as="h3">{t('recording.copy_recording_urls')}</Popover.Header>
      <Popover.Body>
        {recording?.visibility !== 'Unpublished' && formats?.map((format) => (
          <Button
            onClick={() => copyRecordingUrl.mutate(
              { record_id: recording.record_id, format: format.recording_type },
              { onSuccess: () => onCopied() },
            )}
            className={`btn-sm rounded-pill me-1 mt-1 border-0 btn-format-${format.recording_type.toLowerCase()}`}
            key={`${format.recording_type}-${format.url}`}
          >
            {format.recording_type}
          </Button>
        ))}
      </Popover.Body>
    </Popover>
  );
});

export default CopyRecordingPopover;

CopyRecordingPopover.propTypes = {
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
    protectable: PropTypes.bool,
    recorded_at: PropTypes.string.isRequired,
    map: PropTypes.func,
    user_name: PropTypes.string,
  }).isRequired,
  formats: PropTypes.arrayOf(PropTypes.shape({
    url: PropTypes.string.isRequired,
    recording_type: PropTypes.string.isRequired,
  })).isRequired,
  onCopied: PropTypes.func.isRequired,
};
