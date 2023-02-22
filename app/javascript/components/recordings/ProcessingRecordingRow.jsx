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

import { VideoCameraIcon } from '@heroicons/react/24/outline';
import React from 'react';
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function ProcessingRecordingRow() {
  const { t } = useTranslation();

  return (
    <tr id="room-recordings" className="align-middle text-muted border border-2">
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
