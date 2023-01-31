import React from 'react';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      {/* Name */}
      <td className="border-0 py-2 lg-td-placeholder">
        <Placeholder width={6} size="md" />
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
