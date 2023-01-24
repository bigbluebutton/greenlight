import React from 'react';
import { Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { VideoCameraIcon } from '@heroicons/react/24/outline';

export default function EmptyRecordingsList() {
  const { t } = useTranslation();

  return (
    <div className="pt-3">
      <Card className="border-0 shadow-sm text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <VideoCameraIcon className="hi-l pt-4 text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> { t('recording.recordings_list_empty') }</Card.Title>
          <Card.Text>
            { t('recording.recordings_list_empty_description') }
          </Card.Text>
        </Card.Body>
      </Card>
    </div>
  );
}
