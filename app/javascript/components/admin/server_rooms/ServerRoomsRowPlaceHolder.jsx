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
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      {/* Name */}
      <td className="border-0 py-2 lg-td-placeholder">
        <Placeholder width={8} size="md" />
        <Placeholder width={10} size="lg" />
      </td>
      {/* Owner name */}
      <td className="border-0 py-4 sm-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      {/* Room ID */}
      <td className="border-0 py-4 sm-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      {/* # of participants */}
      <td className="border-0 py-4 xs-td-placeholder">
        <Placeholder width={6} size="md" />
      </td>
      {/* status */}
      <td className="border-0 py-4 xs-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
    </tr>
  );
}
