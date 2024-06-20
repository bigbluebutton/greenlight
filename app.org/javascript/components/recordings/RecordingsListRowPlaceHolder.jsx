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
import { Stack } from 'react-bootstrap';
import Placeholder from '../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../shared_components/utilities/RoundPlaceholder';

export default function RecordingsListRowPlaceHolder() {
  return (
    <tr>
      {/* Avatar and Name */}
      <td className="border-0 pt-2 lg-td-placeholder">
        <Stack direction="horizontal">
          <RoundPlaceholder size="small" className="ms-1 me-3" />
          <Stack>
            <Placeholder width={10} size="lg" />
            <Placeholder width={10} size="md" />
          </Stack>
        </Stack>
      </td>
      {/* Length */}
      <td className="border-0 pt-3 xs-td-placeholder">
        <Placeholder width={8} size="md" />
      </td>
      {/* # of Users */}
      <td className="border-0 pt-3 xs-td-placeholder">
        <Placeholder width={4} size="md" />
      </td>
      {/* Visibility */}
      <td className="border-0 pt-3 md-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      {/* Formats */}
      <td className="border-0 pt-3 md-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
    </tr>
  );
}
