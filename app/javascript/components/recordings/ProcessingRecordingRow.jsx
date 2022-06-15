import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faVideo } from '@fortawesome/free-solid-svg-icons';
import React from 'react';
import { Stack } from 'react-bootstrap';

export default function ProcessingRecordingRow() {
  return (
    <tr className="align-middle">
      <td className="text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
            <FontAwesomeIcon icon={faVideo} className="text-primary" />
          </div>
          Processing Recording...
        </Stack>
      </td>
      <td />
      <td />
      <td />
      <td />
      <td />
    </tr>
  );
}
