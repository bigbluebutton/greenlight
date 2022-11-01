import { VideoCameraIcon } from '@heroicons/react/24/outline';
import React from 'react';
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function ProcessingRecordingRow() {
  const { t } = useTranslation();

  return (
    <tr className="align-middle">
      <td className="text-dark border-end-0">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
            <VideoCameraIcon className="hi-s text-brand" />
          </div>
          { t('recording.processing_recording') }
        </Stack>
      </td>
      <td className="border-0" />
      <td className="border-0" />
      <td className="border-0" />
      <td className="border-0" />
      <td className="border-0" />
    </tr>
  );
}
