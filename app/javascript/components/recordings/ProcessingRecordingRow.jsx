import { VideoCameraIcon } from '@heroicons/react/outline';
import React from 'react';
import { Stack } from 'react-bootstrap';

export default function ProcessingRecordingRow() {
  return (
    <tr className="align-middle">
      <td className="text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
            <VideoCameraIcon className="hi-s text-brand" />
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
