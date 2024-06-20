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
import { Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { VideoCameraIcon } from '@heroicons/react/24/outline';

export default function EmptyRecordingsList() {
  const { t } = useTranslation();

  return (
    <div id="recordings-list-empty" className="pt-3">
      <Card className="border-0 card-shadow text-center">
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
